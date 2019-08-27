#!/usr/bin/perl

##      by Hao


##input file

##ATPG


##
my @dir_atpg_file = ();

################################################

##VCS
my @dir_vcs_file = ();


################################################
my $file_count = 0;


my $in_data;
my $out_data;

my $cov;
my $total_pat;

my $vcs_ser;
my $vcs_par;

open ($out_data, ">CPUSS_report.list");

print $out_data "==========================================================================================\n";
printf ($out_data "%10s%20s%20s%20s%20s\n", ATPG, dc_byp, dc_cmp, ac_byp, ac_cmp);
print $out_data "------------------------------------------------------------------------------------------\n";
printf ($out_data "%10s%10s%10s%10s%10s%10s%10s%10s%10s\n", block, cov, pat, cov, pat, cov, pat, cov, pat);
print $out_data "==========================================================================================\n";


#ATPG
foreach $atpg_file (@dir_atpg_file){

    if($file_count % 4 == 0){
        if($atpg_file =~ /\/atpg_CPUSS_(\w+)/){
            printf ($out_data "%10s", $1);
        }
    }


    if(-e $atpg_file){
        open ($in_data, "$atpg_file");

        while(<$in_data>){
            chomp;

            @x = split(" ", $_);

            if(($x[0].$x[1]) =~ /testcoverage/){
                $cov = $x[2];
            }

            if(($x[0].$x[1]) =~ /internalpatterns/){
                $total_pat = $x[2];
            }
        }
        printf ($out_data "%10s", $cov);
        printf ($out_data "%10s", $total_pat);


        close ($in_data);
    }
    else{
        printf ($out_data "%10s%10s", "--", "--");
    }

    if($file_count % 4 == 3){
        print $out_data "\n";
    }

    $file_count++;
}
#######################################
my $file_count = 0;

print $out_data "==========================================================================================\n";
print $out_data "\n\n";
print $out_data "==========================================================================================\n";
printf ($out_data "%10s%20s%20s%20s%20s\n", VCS, dc_byp, dc_cmp, ac_byp, ac_cmp);
print $out_data "------------------------------------------------------------------------------------------\n";
printf ($out_data "%10s%10s%10s%10s%10s%10s%10s%10s%10s\n", block, ser, par, ser, par, ser, par, ser, par);
print $out_data "==========================================================================================\n";


#VCS
foreach $vcs_file (@dir_vcs_file){
    if($file_count % 8 == 0){
        if($vcs_file =~ /\/atpg_CPUSS_(\w+)/){
            printf ($out_data "%10s", $1);
        }
    }

    $vcs_ser = 0;
    $vcs_par = 0;

    if(-e $vcs_file){
        open ($in_data, "$vcs_file");

        while(<$in_data>){
            chomp;

            @x = split(" ", $_);

            if(($x[1].$x[2]) =~ /Startingserial/){
                $vcs_ser += $x[5];
            }

            if(($x[1].$x[2]) =~ /Startingparallel/){
                $vcs_par += $x[5];
            }
        }

        if($vcs_file =~ /sim_s/){
            printf($out_data "%10s", $vcs_ser);
        }
        if($vcs_file =~ /sim_p/){
            printf($out_data "%10s", $vcs_par);
        }

        close ($in_data);
    }
    else{
        printf($out_data "%10s", "--");
    }

    if($file_count % 8 == 7){
        print $out_data "\n";
    }

    $file_count++;
}

close ($out_data);
