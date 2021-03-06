#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;

my $port = 31559;
my $score_len = 16;
my $score_file = 'cave9-global.hi';
$|=1;

my $hiscore = eval { do $score_file } || "0";
print time.":hiscore:$hiscore\n";

my $sock = IO::Socket::INET->new(
	LocalPort => $port,
	Proto     => "udp",
	) or die "Couldn't be a udp server on port $port : $@\n";
print time.":udp:".$sock->sockport."\n";

my $score;
while ($sock->recv($score, $score_len)) {
	my($port, $addr) = sockaddr_in($sock->peername);
	my $host = gethostbyaddr($addr, AF_INET);
	if($score =~ /^\d+/) {
		$score = $&;
		if($& > $hiscore) {
			$hiscore = $&;
			print time.":$host:$score!\n";
			open SCORE, ">$score_file" 
				or die "open $score_file: $!";
			print SCORE $hiscore;
			close SCORE;
		} else {
			print time.":$host:$score<$hiscore\n";
		}
	} else {
		print time.":$host<$hiscore\n";
	}
	$sock->send($hiscore);
} 
die "recv: $!";
