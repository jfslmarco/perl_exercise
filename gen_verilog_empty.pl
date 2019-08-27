#!usr/bin/perl
#########################################################
#            The following is an example.
#
#       perl gen_verilog_empty.pl (file path) (module name)
#
# EX:   perl gen_verilog_empty.pl ./path/Top.v Top
#
#########################################################
my $state = "SEARCH";

if(!-e $ARGV[0]){
    printf "ERROR!!! The file ".$ARGV[0]." is not exist.\n";
    printf "Please enter the correct file path.\n";
    printf "The following is an example.\n";
    printf "perl perl_name (file path) (module name)\n";
    printf "perl gen_verilog_empty.pl ./path/Top.v Top\n";
    exit;
}

##define print pin sort
my @pin_sort = qw /inout input output/;

my $type_tmp;
my $bits_tmp;

my $pin_count = 0;
my $pin_count_out_data = 0;
my $pin_type_count_out_data = 0;

my $in_data;
my $out_data;

my $out_file_name;


open ($in_data, "$ARGV[0]");
##read file
while(<$in_data>){
    chomp;

    $_ =~ s/,/ /g;

    if($state eq "SEARCH"){
        if($_ =~ /\s*module\s+(\w+)\s*\(/){
            $module_name = $1;
#            print "$module_name\n";
#            print "$user_module_name\n";

            if($module_name eq $ARGV[1]){
                $state = "IDLE";
                print "########## Generating empty.v ##########\n";
                print "input verilog : $ARGV[0]\n";
                print "module name : $ARGV[1]\n";
                print "########################################\n";
                print "output file: $ARGV[1]_empty.v\n";

            }
        }
    }

    if($state ne "SEARCH" && $state ne "DONE"){
        if($_ =~ /\s*(input)/ || $_ =~/\s*(output)/ || $_ =~/\s*(inout)/){
            $state = $1;

            if($_ =~ /\;/){
                $state = "IDLE";
                $_ =~ s/;/ /;
            }

            if($_ =~ /\s*(\w+)\s+\[(\d+)\:0\]/){
                $type_tmp = $1;
                $bits_tmp = $2;

                $_ =~ s/]/ /;
                @x = split(" ", $_);
                shift @x;
                shift @x;
                foreach $pin (@x){
                    $pin_type{"$pin"} = $type_tmp;
                    $pin_bits{"$pin"} = $bits_tmp;
                    $pin_count++;
#                    print "$type_tmp\n";
#                    print "$bits_tmp\n";
#                    print "$pin\n";
                }
            }

            elsif($_ =~ /\s*(\w+)/){
                $type_tmp = $1;
                $bits_tmp = 0;
                @x = split(" ", $_);
                shift @x;
                foreach $pin (@x){
                    $pin_type{"$pin"} = $type_tmp;
                    $pin_bits{"$pin"} = $bits_tmp;
                    $pin_count++;
#                    print "$type_tmp\n";
#                    print "$bits_tmp\n";
#                    print "$pin\n";
                }
            }
        }

        elsif($state ne "IDLE"){

            if($_ =~ /\;/){
                $state = "IDLE";
                $_ =~ s/;/ /;
            }
            @x = split(" ", $_);
            foreach $pin (@x){
                $pin_type{"$pin"} = $type_tmp;
                $pin_bits{"$pin"} = $bits_tmp;
                $pin_count++;
#                print "$type_tmp\n";
#                print "$bits_tmp\n";
#                print "$pin\n";
            }
        }
    }

    if($state eq "IDLE"){
        if($_ =~ /endmodule/){
            $state = "DONE";
        }
    }

    if($state eq "DONE"){
        break;
    }

}
close ($in_data);
########################################

if($state eq "SEARCH"){
    printf "ERROR!!! The module ".$ARGV[1]." is not exist.\n";
    printf "Please enter the correct module name.\n";
    printf "The following is an example.\n";
    printf "perl perl_name (file path) (module name)\n";
    printf "perl gen_verilog_empty.pl ./path/Top.v Top\n";
    exit;
}

$out_file_name = "$ARGV[1]"."_empty.v";
open ($out_data, ">$out_file_name");

##print pin
printf $out_data "module $module_name (\n";

foreach $pin_direction (@pin_sort){
    foreach $pin (sort keys %pin_type){
        if($pin_type{$pin} eq $pin_direction){

            if($pin_type_count_out_data == 0){
                printf $out_data "//"."$pin_direction\n";
            }

            printf $out_data "$pin";
            $pin_count_out_data++;
            $pin_type_count_out_data++;

            if($pin_count_out_data == $pin_count){
                printf $out_data "\n);\n\n";
            }
            else{
                printf $out_data ",\n";
            }

        }
    }
    $pin_type_count_out_data = 0;
}
########################################

##print inout input output
foreach $pin_direction (@pin_sort){
    printf $out_data "\n";

    foreach $pin (sort keys %pin_type){
        if($pin_type{$pin} eq $pin_direction){

            if($pin_bits{$pin} != 0){
                printf $out_data "$pin_direction [$pin_bits{$pin}:0] $pin;\n";
            }
            else{
                printf $out_data "$pin_direction $pin;\n";
            }
        }
    }
}
########################################
printf $out_data "\n\n\n";



##print wire
foreach $pin (sort keys %pin_type){
    if($pin_type{$pin} eq "output"){

        if($pin_bits{$pin} != 0){
            printf $out_data "wire [$pin_bits{$pin}:0] $pin;\n";
        }
        else{
            printf $out_data "wire $pin;\n";
        }
    }
}
########################################
printf $out_data "\n\n\n";


##print output value
foreach $pin (sort keys %pin_type){
    if($pin_type{$pin} eq "output"){
        printf $out_data "assign $pin = ".($pin_bits{$pin}+1)."'d0;\n";
    }
}
########################################
printf $out_data "\n\n\n";

printf $out_data "endmodule\n";


close ($out_data);
