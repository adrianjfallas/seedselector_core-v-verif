#!/usr/bin/env perl

use strict 'vars';
use warnings;

my $file = "merged_functional_coverage_detailed.log";

#Instance name: uvm_pkg.uvm_test_top.env.cov_model.debug_covg
#Type name: uvme_cv32e40p_pkg
#File name: /nis/asic/cr_dump2/fallasad/SeedSelector_Ubuntu/seedselector_cv32e40p/cv32e40p/env/uvme/uvme_cv32e40p_pkg.sv
#Include Files:
#    /nis/asic/cr_dump2/fallasad/SeedSelector_Ubuntu/seedselector_cv32e40p/cv32e40p/env/uvme/cov/uvme_interrupt_covg.sv
#    /nis/asic/cr_dump2/fallasad/SeedSelector_Ubuntu/seedselector_cv32e40p/cv32e40p/env/uvme/cov/uvme_debug_covg.sv
#    /nis/asic/cr_dump2/fallasad/SeedSelector_Ubuntu/seedselector_cv32e40p/cv32e40p/env/uvme/cov/uvme_rv32isa_covg.sv
#Number of covered cover bins: 88 of 183
#Number of uncovered cover bins: 95 of 183
#
#Name                           Average, Covered Grade         Line  Source Code
#---------------------------------------------------------------------------------------------------
#cg_debug_mode_ext              7.69%, 7.69% (1/13)            44 (uvme_debug_covg.sv) covergroup cg_debug_mode_ext ;
#|--state                       7.69% (1/13)                   46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[RESET]               100.00% (1/1)                  46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[BOOT_SET]            0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[SLEEP]               0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[WAIT_SLEEP]          0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[FIRST_FETCH]         0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[DECODE]              0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[FLUSH_EX]            0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[FLUSH_WB]            0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[XRET_JUMP]           0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[DBG_TAKEN_ID]        0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[DBG_TAKEN_IF]        0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[DBG_FLUSH]           0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#| |--auto[DBG_WAIT_BRANCH]     0.00% (0/1)                    46 (uvme_debug_covg.sv) state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
#cg_ebreak_execute_with_ebreakm 20.00%, 20.00% (1/5)           55 (uvme_debug_covg.sv) covergroup cg_ebreak_execute_with_ebreakm;
#|--ex                          0.00% (0/1)
#| |--active                    0.00% (0/1)                    58 (uvme_debug_covg.sv) bins active = {1};
#|--ebreakm_set                 0.00% (0/1)                    60 (uvme_debug_covg.sv) ebreakm_set: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[15] {
#| |--active                    0.00% (0/1)

open LOG, "$file" or die "Can't open [$file]: $!\n";
my @lines = <LOG>;
close LOG;

print "`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\n";
print "function int build_base_covmodel_tree(int influence_param_1);\n\n";
print "\tstring s;\n";
print "\tint base_tree_weight;\n";
print "\tint seed_tree_weight;\n";
print "\tint seed_selector_result;\n";
print "\tTreeNode base_covermodel;\n";

my $instance_name;
my $instance_found= 0;
my $instance_begin= 0;
my $instance_end= 0;

my $cover_item_number=1;
my $cover_item_name;
my $cover_item_functional_cov_overall_covered = 0;
my $cover_item_functional_cov_points_covered = 0;
my $cover_item_functional_cov_points_total = 0;

my $cover_group_number=0;
my $cover_point_number=0;
my $cover_value_number=0;

#First define the TreeNode handlers
foreach my $line(@lines) {
   #Find start of instance
   if($line =~ /Instance\sname:\s(\S+)/) {
      $instance_name = $1;
   };
   if($instance_found) {
      $instance_found = 0;
      $instance_begin = 1;
      $instance_end = 0;
      #Division line
      next
   };
   if($line =~ /Name.*Covered/) {
      $instance_found = 1;
      $instance_begin = 0;
      $instance_end = 1;
   };
   if($instance_begin and !$instance_end) {

      #Covergroups
      #Regexp example
      #cg_debug_mode_ext              7.69%, 7.69% (1/13)            44 (uvme_debug_covg.sv) covergroup cg_debug_mode_ext ;
      if($line =~ /(\S+)\s+(\S+)%,\s+(\S+)%\s+\((\d+)\/(\d+)\).*covergroup/) {
         $cover_item_name = $1;
         print "\tTreeNode base_covergroup_${cover_group_number};\n";
         $cover_group_number++;
         $cover_item_number++;
      };

      #Coverpoints
      #Regexp example
      #|--nostep                      100.00% (1/1)                  117 (uvme_debug_covg.sv) nostep: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
      #|--cebreak_regular_nodebug     0.00% (0/1)                    120 (uvme_debug_covg.sv) cebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;
      if($line =~ /^\Q|--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*(coverpoint|cross).*/) {
         $cover_item_name = $1;
         print "\tTreeNode base_coverpoint_${cover_point_number};\n";
         $cover_point_number++;
         $cover_item_number++;
      };

      #Covervalues
      #Regexp example
      #| |--active                    100.00% (7776/1)               118 (uvme_debug_covg.sv) bins active = {0};
      #| |--active,active,active      0.00% (0/1)                    120 (uvme_debug_covg.sv) cebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;#
      if($line =~ /^\Q| |--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*/) {
         $cover_item_name = $1;
         print "\tTreeNode base_covervalue_${cover_value_number};\n";
         $cover_value_number++;
         $cover_item_number++;
      };
   };
   if($line =~ /^$/ and $instance_begin) {
      $instance_end = 1;
      $instance_begin = 0;
   };
};

print "\n";
print "\tbase_covermodel = new();\n";
print "\tbase_covermodel.node_id = 1;\n";
print "\tbase_covermodel.name = \"root\";\n\n";

#Reset var values
$instance_found= 0;
$instance_begin= 0;
$instance_end= 0;

$cover_item_number=1;
$cover_item_functional_cov_overall_covered = 0;
$cover_item_functional_cov_points_covered = 0;
$cover_item_functional_cov_points_total = 0;

$cover_group_number=0;
$cover_point_number=0;
$cover_value_number=0;

#Then, define each TreeNode atributes
foreach my $line(@lines) {
   #Find start of instance
   if($line =~ /Instance\sname:\s(\S+)/) {
      $instance_name = $1;
   };
   if($instance_found) {
      $instance_found = 0;
      $instance_begin = 1;
      $instance_end = 0;
      #Division line
      next
   };
   if($line =~ /Name.*Covered/) {
      $instance_found = 1;
      $instance_begin = 0;
      $instance_end = 1;
   };
   if($instance_begin and !$instance_end) {

      #Covergroups
      #Regexp example
      #cg_debug_mode_ext              7.69%, 7.69% (1/13)            44 (uvme_debug_covg.sv) covergroup cg_debug_mode_ext ;
      if($line =~ /(\S+)\s+(\S+)%,\s+(\S+)%\s+\((\d+)\/(\d+)\).*covergroup/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $3;
         $cover_item_functional_cov_points_covered = $4;
         $cover_item_functional_cov_points_total = $5;
         print "\tbase_covergroup_${cover_group_number} = new();\n";
         print "\tbase_covergroup_${cover_group_number}.node_id = $cover_item_number;\n";
         print "\tbase_covergroup_${cover_group_number}.name = \"$cover_item_name\";\n";
         print "\tbase_covergroup_${cover_group_number}.level = 1;\n";
         print "\tbase_covergroup_${cover_group_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_covergroup_${cover_group_number}.add_influence_param_data();\n";
         print "\tbase_covermodel.add_child(base_covergroup_${cover_group_number});\n\n";
         $cover_group_number++;
      };

      #Coverpoints
      #Regexp example
      #|--nostep                      100.00% (1/1)                  117 (uvme_debug_covg.sv) nostep: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
      #|--cebreak_regular_nodebug     0.00% (0/1)                    120 (uvme_debug_covg.sv) cebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;
      if($line =~ /^\Q|--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*(coverpoint|cross).*/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $2;
         $cover_item_functional_cov_points_covered = $3;
         $cover_item_functional_cov_points_total = $4;
         print "\tbase_coverpoint_${cover_point_number} = new();\n";
         print "\tbase_coverpoint_${cover_point_number}.node_id = $cover_item_number;\n";
         print "\tbase_coverpoint_${cover_point_number}.name = \"$cover_item_name\";\n";
         print "\tbase_coverpoint_${cover_point_number}.level = 2;\n";
         print "\tbase_coverpoint_${cover_point_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_coverpoint_${cover_point_number}.add_influence_param_data();\n";
         $cover_group_number--;
         print "\tbase_covergroup_${cover_group_number}.add_child(base_coverpoint_${cover_point_number});\n\n";
         $cover_group_number++;
         $cover_point_number++;
      };

      #Covervalues
      #Regexp example
      #| |--active                    100.00% (7776/1)               118 (uvme_debug_covg.sv) bins active = {0};
      #| |--active,active,active      0.00% (0/1)                    120 (uvme_debug_covg.sv) cebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;#
      if($line =~ /^\Q| |--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $2;
         $cover_item_functional_cov_points_covered = $3;
         $cover_item_functional_cov_points_total = $4;
         print "\tbase_covervalue_${cover_value_number} = new();\n";
         print "\tbase_covervalue_${cover_value_number}.node_id = $cover_item_number;\n";
         print "\tbase_covervalue_${cover_value_number}.name = \"$cover_item_name\";\n";
         print "\tbase_covervalue_${cover_value_number}.level = 3;\n";
         print "\tbase_covervalue_${cover_value_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_covervalue_${cover_value_number}.add_influence_param_data();\n";
         $cover_point_number--;
         print "\tbase_coverpoint_${cover_point_number}.add_child(base_covervalue_${cover_value_number});\n\n";
         $cover_point_number++;
         $cover_value_number++;
      };
   };
   if($line =~ /^$/ and $instance_begin) {
      $instance_end = 1;
      $instance_begin = 0;
   };
};

print"\tbase_covermodel.print_tree(1);\n\n";

print"\tbase_tree_weight = base_covermodel.get_tree_weight();\n";
print"\ts.itoa(base_tree_weight);\n";
print"\t\$display({\"SEED_SELECTOR: base tree weight : \", s});\n\n";
print"\tbase_covermodel.update_seed_tree_weight(influence_param_1);\n\n";
print"\tseed_tree_weight = base_covermodel.get_tree_weight();\n";
print"\ts.itoa(seed_tree_weight);\n";
print"\t\$display({\"SEED_SELECTOR: seed tree weight : \", s});\n\n";
print"\tif (base_tree_weight > seed_tree_weight) begin\n";
print"\t\tseed_selector_result = 0;\n";
print"\t\t\$display(\"SEED_SELECTOR: APPROVED\");\n";
print"\tend\n";
print"\telse begin\n";
print"\t\tseed_selector_result = 7;\n";
print"\t\t\$display(\"SEED_SELECTOR: DISCARDED\");\n";
print"\tend\n";
print"\treturn seed_selector_result;\n";
print"endfunction";
exit 1;


#`include "../../run/seed_selector/cov_tree_defs_and_methods.sv"
#
#function void build_base_covmodel_tree();
#
#   TreeNode base_covermodel;
#	 TreeNode base_covergroup_0;
#	 TreeNode base_coverpoint_0;
#	 TreeNode base_covervalue_0;
#	 TreeNode base_covervalue_1;
#	 TreeNode base_coverpoint_1;
#	 TreeNode base_covervalue_2;
#	 TreeNode base_covervalue_3;
#
#   base_covermodel = new();
#   base_covermodel.node_id = 1;
#   base_covermodel.name = "root";
#
#   base_covergroup_0 = new();
#   base_covergroup_0.node_id = 2;
#   base_covergroup_0.name = "axi4";
#   base_covergroup_0.level = 1;
#	 base_covergroup_0.set_cov_data(38.88, 229, 589);
#	 base_covermodel.add_child(base_covergroup_0);
#	 base_covermodel.add_influence_param_data();
