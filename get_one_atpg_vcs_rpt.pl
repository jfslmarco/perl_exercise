#!/usr/bin/perl

##  by KJ


my $in_f;
my $out_f;

my $corner = $ARGV[0];
my $block = $ARGV[1];

my $top;
if ($block eq "SOICSS") {
  $top = "SOICSS" ;
} else {
  $top = "CPUSS";
}
#print "$top\n";

my @all_mode = qw /cmp_dc byp_dc cmp_ac byp_ac/;

my @all_vcs_mode = qw /s p/;


###generate ATPG report

foreach $mode (@all_mode) {
    $input_files =  "ATPG\/$corner\/atpg_CPUSS_$block\/$top\/DFT\/atpg_$mode/run.log";
    print "parsing atpg report: $input_files \n";

    open($in_f, "$input_files");
    open($out_f, ">./rpt/$corner/atpg_CPUSS_${block}_atpg_summary.rpt");

    while (<$in_f>) {
      if ($_ =~ /test coverage\s+([0-9]+\.[0-9]+)/) {
              $test_cov{"$mode"} = $1;
      }
      if ($_ =~ /internal patterns\s+([0-9]+)/) {
              $test_pat{"$mode"} = $1;
      }
      if (($_ =~ /Error/) || ($_ =~ /Process terminated by kill/)) {
              $test_cov{"$mode"} = "ERROR";
              $test_pat{"$mode"} = "ERROR";
      }

    }
          #print  "test coverage($mode) = $test_cov{$mode}\n";
          #print  "test pattern($mode) = $test_pat{$mode}\n";


    #print 'Output file: CPUSS.gpu_top_X.vg'."\n\n";
    close($in_f);
}
printf $out_f "\tdc_cmp\t\tdc_byp\t\tac_cmp\t\tac_byp\n";
printf $out_f "block\tcov\tpat\tcov\tpat\tcov\tpat\tcov\tpat\n";
printf $out_f "$block\t$test_cov{cmp_dc}\t$test_pat{cmp_dc}\t$test_cov{byp_dc}\t$test_pat{byp_dc}\t$test_cov{cmp_ac}\t$test_pat{cmp_ac}\t$test_cov{byp_ac}\t$test_pat{byp_ac}\n";

close($out_f);


##generate VCS report


foreach $mode (@all_mode) {
  foreach $vcs_mode (@all_vcs_mode) {

    $input_files =  "ATPG\/$corner\/atpg_CPUSS_$block\/$top\/DFT\/sim_${vcs_mode}_${mode}_run_XTB_summary.rpt";
    my $vcs_log = "ATPG\/$corner\/atpg_CPUSS_$block\/$top\/DFT\/sim_${vcs_mode}_${mode}_run/run.log";
    print "parsing vcs report: $input_files \n";

    open($in_f, "$input_files");
    open($out_f, ">./rpt/$corner/atpg_CPUSS_${block}_vcs_summary.rpt");
    open($out2_f, ">./rpt/$corner/atpg_CPUSS_${block}_vcs_run_patterns.rpt");

    if (!-e $vcs_log){
       $vcs_results{"${vcs_mode}_${mode}"} = 'N.A.';
    } elsif (!-e $in_f){
       $vcs_results{"${vcs_mode}_${mode}"} = 'RUN';
    }
    
    while (<$in_f>) {
      if ($_ =~ /Simulation of ([0-9]+) patterns completed with ([0-9]+) mismatches/) {
        if ($2 == 0) {
       $vcs_results{"${vcs_mode}_${mode}"} = PASS;
       $vcs_pat{"${vcs_mode}_${mode}"} = $vcs_pat{"${vcs_mode}_${mode}"} + $1;
    }
    else {
       $vcs_results{"${vcs_mode}_${mode}"} = FAIL;
       $vcs_pat{"${vcs_mode}_${mode}"} = $vcs_pat{"${vcs_mode}_${mode}"} + $1;
    }

      } else {
       $vcs_results{"${vcs_mode}_${mode}"} = ERROR;
      }


    }
         $current_vcs = "${vcs_mode}_${mode}";
     #print  "${vcs_mode}_${mode} = $vcs_results{$current_vcs} \n";


  }
    #print 'Output file: CPUSS.gpu_top_X.vg'."\n\n";
    close($in_f);
}
printf $out_f "\t\tdc_cmp\t\tdc_byp\t\tac_cmp\t\tac_byp\n";
printf $out_f "block\t\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\n";
printf $out_f "$block\t$vcs_results{p_cmp_dc}\t$vcs_results{s_cmp_dc}\t$vcs_results{p_byp_dc}\t$vcs_results{s_byp_dc}\t$vcs_results{p_cmp_ac}\t$vcs_results{s_cmp_ac}\t$vcs_results{p_byp_ac}\t$vcs_results{s_byp_ac}\n";

close($out_f);


printf $out2_f "\t\tdc_cmp\t\tdc_byp\t\tac_cmp\t\tac_byp\n";
printf $out2_f "block\t\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\n";
printf $out2_f "$block\t$vcs_pat{p_cmp_dc}\t$vcs_pat{s_cmp_dc}\t$vcs_pat{p_byp_dc}\t$vcs_pat{s_byp_dc}\t$vcs_pat{p_cmp_ac}\t$vcs_pat{s_cmp_ac}\t$vcs_pat{p_byp_ac}\t$vcs_pat{s_byp_ac}\n";

close($out2_f);


my $vcs_done = 0;

foreach $mode (@all_mode) {
  foreach $vcs_mode (@all_vcs_mode) {

    $input_files =  "ATPG\/$corner\/atpg_CPUSS_$block\/$top\/DFT\/sim_${vcs_mode}_${mode}_run/run.log";
    print "$input_files\n";

    open($in_f, "$input_files");
    open($out_f, ">./rpt/$corner/atpg_CPUSS_${block}_vcs_status.rpt");

    if (!-e $input_files){
       $vcs_results{"${vcs_mode}_${mode}"} = 'N.A.';
    } elsif (!-e $in_f){
       $vcs_results{"${vcs_mode}_${mode}"} = 'RUN ';
    }

    $vcs_done = 0;
    $vcs_pat{"${vcs_mode}_${mode}"} = 0;
    while (<$in_f>) {
    
    if ($_ =~ /scan load for pattern ([0-9]+)/) {
       $vcs_results{"${vcs_mode}_${mode}"} = "RUN ";
       $vcs_pat{"${vcs_mode}_${mode}"} = $1;
      } elsif ($_ =~ /Simulation of ([0-9]+) patterns completed with ([0-9]+) mismatches/){
           if ($2 == 0) {
               $vcs_results{"${vcs_mode}_${mode}"} = PASS;
       } else {
               $vcs_results{"${vcs_mode}_${mode}"} = FAIL;
       }
       $vcs_pat{"${vcs_mode}_${mode}"} = $1;
       $vcs_done = 1;
      } elsif (($vcs_done = 0) && ($_ =~ /Job Finished/)) {
       $vcs_results{"${vcs_mode}_${mode}"} = "ERR ";

      }



    }
    #print 'Output file: CPUSS.gpu_top_X.vg'."\n\n";
    close($in_f);

  }
}

printf $out_f "\t\tdc_cmp\t\tdc_byp\t\tac_cmp\t\tac_byp\n";
printf $out_f "block\t\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\tpara\.\tserial\n";
printf $out_f "$block\t$vcs_pat{p_cmp_dc}($vcs_results{p_cmp_dc})\t$vcs_pat{s_cmp_dc}($vcs_results{s_cmp_dc})\t$vcs_pat{p_byp_dc}($vcs_results{p_byp_dc})\t$vcs_pat{s_byp_dc}($vcs_results{s_byp_dc})\t$vcs_pat{p_cmp_ac}($vcs_results{p_

close($out_f);
