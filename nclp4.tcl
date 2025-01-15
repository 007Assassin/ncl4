set ns [new Simulator]
set tracefile [open 4.tr w]
$ns trace-all $tracefile
set namfile [open 4.nam w]
$ns namtrace-all $namfile
set s [$ns node]
set c [$ns node]
$ns color 1 Blue
$s label "Server"
$c label "Client"
$ns duplex-link $s $c 10Mb 22ms DropTail
$ns duplex-link-op $s $c orient right
set tcp0 [new Agent/TCP]
$ns attach-agent $s $tcp0
$tcp0 set packetSize_ 1500
set sink0 [new Agent/TCPSink]
$ns attach-agent $c $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$tcp0 set fid_ 1
proc finish {} {
global ns tracefile namfile
$ns flush-trace
close $tracefile
close $namfile
exec nam 4.nam
exec awk -f 5t.awk 4.tr &
exec awk -f 5c.awk 4.tr > con.tr &
exec xgraph con.tr -geometry 800*400 -t "bytes_received_at_client" -x "time_in_sec" -y
"bytes_in_bps" &
}
$ns at 0.01 "$ftp0 start"
$ns at 15.0 "$ftp0 stop"
$ns at 15.1 "finish"
$ns run

#ex5transfer.awk
BEGIN {
    count=0;
    time=0;
    total_bytes_sent=0;
    total_bytes_received=0;
}
{
    if($1=="r" && $4==1 && $5=="tcp")
     total_bytes_sent+=$6;

    if($1=="+" && $3==0 && $5=="tcp")
     total_bytes_received+=$6;
}
END {
    system("clear");
    printf("\n Transmission time required to transfer the file is %f \n",$2);
    printf("\n actual data sent from the server is %f Mbps \n",(total_bytes_sent)/1000000);
    printf("\n data received by the client is %f Mbps \n",(total_bytes_received)/1000000);
}

#ex5convert.awk

BEGIN{
    count=0;
    time=0;
}
{
    if($1=="r" && $4==1 && $5=="tcp")
     {
        count+=$6;
        time=$2;
        printf("\n %f \t %f",time,(count)/1000000);
     }     
}
END {
    
}
