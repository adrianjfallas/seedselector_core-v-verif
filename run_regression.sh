#!/bin/bash

function print_help {
	printf "Usage: %s:
           [-c]                                      : Selected core of the Core-V family.
           [-e]                                      : Activates seed selector.
           [-p] <TARGET_FUNCTIONAL_COVERAGE_PERCENT> : Stops regression when a certain functional coverage percent is reached.
           [-?]                                      : Prints this help.\n" $(basename $0) >&2
}

#-----------------------------------------------------------------
# set defaults
target_functional_coverage_percent=90
seed_selector=0
project="cv32e40x"
sim="xrun"
current_cfg="default"
cfgs_list=(
           "default"
          )
rebuilds=0
start_time=`date +%s%N`
end_time=`date +%s%N`

#-- parse options
while getopts ':c:p:e?:' OPTION
do
	case $OPTION in
		c)	project="${OPTARG}"
			;;
		e)	seed_selector=1
			;;
		p)	target_functional_coverage_percent="${OPTARG}"
			;;
		?)	print_help
			exit 2
			;;
		esac
done
shift $(($OPTIND - 1))

main () {
   time {
      #-----------------------------------------------------------------

      echo ""
      echo "*   _____   ___    ___  ___         _____   ___  _        ___    __ ______   ___   ____          __   ___   ____     ___        __ __         __ __    ___  ____   ____  _____  *"
      echo "*  / ___/  /  _]  /  _]|   \       / ___/  /  _]| |      /  _]  /  ]      | /   \ |    \        /  ] /   \ |    \   /  _]      |  |  |       |  |  |  /  _]|    \ |    ||     | *"
      echo "* (   \_  /  [_  /  [_ |    \     (   \_  /  [_ | |     /  [_  /  /|      ||     ||  D  )      /  / |     ||  D  ) /  [_ _____ |  |  | _____ |  |  | /  [_ |  D  ) |  | |   __| *"
      echo "*  \__  ||    _]|    _]|  D  |     \__  ||    _]| |___ |    _]/  / |_|  |_||  O  ||    /      /  /  |  O  ||    / |    _]     ||  |  ||     ||  |  ||    _]|    /  |  | |  |_   *"
      echo "*  /  \ ||   [_ |   [_ |     |     /  \ ||   [_ |     ||   [_/   \_  |  |  |     ||    \     /   \_ |     ||    \ |   [_|_____||  :  ||_____||  :  ||   [_ |    \  |  | |   _]  *"
      echo "*  \    ||     ||     ||     |     \    ||     ||     ||     \     | |  |  |     ||  .  \    \     ||     ||  .  \|     |       \   /         \   / |     ||  .  \ |  | |  |    *"
      echo "*   \___||_____||_____||_____|      \___||_____||_____||_____|\____| |__|   \___/ |__|\_|     \____| \___/ |__|\_||_____|        \_/           \_/  |_____||__|\_||____||__|    *"
      echo "*                                                                                                                                                                               *"
      echo ""
      echo -e "\n********************************************************************************* "
      echo -e "*** Running regression"
      echo -e "*** Name:   $regression_name"
      echo -e "*** Folder: $regressions_folder"
      echo -e "*** Start date: $start_time"
      echo -e "*********************************************************************************\n "

      case "$project" in
         cv32e40p)
            cfgs_list=(
                       "default"
                      )

            ## Build:corev-dv
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make clean_riscv-dv comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make clean_riscv-dv comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0
            popd > /dev/null
            ## Build:uvmt_cv32e40p
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES
            popd > /dev/null

            #List of tests
              #1.debug_test
              #  description: Debug directed test
              #2.debug_test_reset
              #  description: Debug reset test
              #3.debug_test_trigger
              #  description: Debug trigger test
              #4.debug_test_boot_set
              #  description: Debug reset test with random boot set
              #5.debug_test_known_miscompares
              #  description: Debug test which contains known miscompares
              #6.corev_rand_debug
              #  description: debug random test
              #7.corev_rand_debug_single_step
              #  description: debug random test
              #8.corev_rand_debug_ebreak
              #  description: debug random test

            tests_list=(
                        "debug_test"
                        "debug_test_reset"
                        "debug_test_trigger"
                        "debug_test_boot_set"
                        "debug_test_known_miscompares"
                        "corev_rand_debug"
                        "corev_rand_debug_single_step"
                        "corev_rand_debug_ebreak"
                        )
            ;;
         cv32e40x)
            cfgs_list=(
                       "default"
                      )

            # Build:corev-dv
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0
            popd > /dev/null
            # Build:uvmt_cv32e40x
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES
            popd > /dev/null

            #List of tests
              #1.debug_test
              #  description: Debug directed test
              #2.debug_test_reset
              #  description: Debug reset test
              #3.debug_test_trigger
              #  description: Debug trigger test
              #4.debug_test_boot_set
              #  description: Debug reset test with random boot set
              #5.corev_rand_debug
              #  description: debug random test
              #6.corev_rand_debug_single_step
              #  description: debug random test
              #7.corev_rand_debug_ebreak
              #  description: debug random test

            tests_list=(
                        ##"debug_test"
                        ##"debug_test_reset"
                        ##"debug_test_trigger"
                        ##"debug_test_boot_set"
                        "corev_rand_debug"
                        ##"corev_rand_debug_single_step"
                        ##"corev_rand_debug_ebreak"
                        ##"corev_rand_data_obi_err_debug"
                        ##"corev_rand_instr_obi_err_debug"
                        ##"corev_rand_interrupt_debug"
                        )
            ;;
         cv32e40s)
            cfgs_list=(
                       "default"
                      )

            # Build:corev-dv
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=0  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=0
            popd > /dev/null
            # Build:uvmt_cv32e40s
            echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=YES  ]"
            pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
            make comp CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=YES
            popd > /dev/null

            #List of tests
             #1.debug_test
             #   description: Debug directed test
             #2.debug_test_reset
             #   description: Debug reset test
             #3.debug_test_trigger
             #   description: Debug trigger test
             #4.debug_test_boot_set
             #   description: Debug reset test with random boot set
             #5.corev_rand_debug
             #   description: debug random test
             #6.corev_rand_debug_single_step
             #   description: debug random test
             #7.corev_rand_debug_ebreak
             #   description: debug random test

            tests_list=(
                        ##"debug_test"
                        ##"debug_test_reset"
                        ##"debug_test_trigger"
                        ##"debug_test_boot_set"
                        "corev_rand_debug"
                        ##"corev_rand_debug_single_step"
                        ##"corev_rand_debug_ebreak"
                        ##"corev_rand_data_obi_err_debug"
                        ##"corev_rand_instr_obi_err_debug"
                        ##"corev_rand_interrupt_debug"
                        ##"debug_priv_test"
                        ##"debug_test_0_triggers"
                        ##"pma_debug"
                        )
            ;;
      esac

      num_tests=${#tests_list[*]}
      test_runs=0

      if [ "$seed_selector" -ne 0 ]
      then
         echo "Creating seed_selector folder"
         mkdir $regression_path/seed_selector/

         cp -v ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/seed_selector.sv $regression_path/seed_selector/
         cp -v ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/cov_tree_defs_and_methods.sv $regression_path/seed_selector/
         echo -e "\`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\nfunction int build_base_covmodel_tree(int influence_param_1);\n\n\t\$display(\"SEED_SELECTOR: First test run, no coverage tree yet.\");\n\nendfunction" > ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/tree_cov_model_base.sv
         cp -v ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/tree_cov_model_base.sv $regression_path/seed_selector/
         echo -e "\n"
      fi

      until [[ $(($total_functional_coverage_percent)) -ge $(($target_functional_coverage_percent)) ]]
      do
         num_cfgs=${#cfgs_list[*]}
         cfg_idx=$(($RANDOM % $num_cfgs))
         current_cfg=${cfgs_list[$cfg_idx]}

         test_idx=$(($RANDOM % $num_tests))

         current_test=${tests_list[$test_idx]}
         echo -e "\n\n\n"
         echo -e "###################################################################################"
         echo "$current_test"
         current_test_run="$current_test"__`date +"%Y_%m_%d__%H_%M_%S"`
         current_test_run_path="$regression_path"/"$current_test_run"
         echo -e "Running test: $current_test_run"
         mkdir $current_test_run_path
         cd $current_test_run_path
         random_seed=$RANDOM

         if [ "$seed_selector" -ne 0 ]
         then
            cd ${CORE_V_VERIF}/$project/sim/uvmt
            if [[ $current_test =~ corev* ]]
            then
               echo "Running test: [cd $CORE_V_VERIF/$project/sim/uvmt && make gen_corev-dv test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed SEED_SELECTOR=$seed_selector]"
               make gen_corev-dv test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed USER_RUN_FLAGS=+SEED_SELECTOR_$current_test;
            else
               echo "Running test: [cd $CORE_V_VERIF/$project/sim/uvmt && make test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed SEED_SELECTOR=$seed_selector]"
               make test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed USER_RUN_FLAGS=+SEED_SELECTOR_$current_test;
            fi
            if [ "$test_runs" -gt 0 ]
            then
               cd $regression_path/xrun_results/$current_cfg/$current_test/0/
               ${CORE_V_VERIF}/seed_selector_parsing.pl xrun-$current_test.log
               ## If seed selector discards
               if [ "$?" -eq 7 ]
               then
                   cd $regression_path
                   echo -e "Removing $current_test_run since it was discarded by the seed selector...\n\n"
                   rm -rf $current_test_run_path
                   echo -e "$current_test_run random_seed: $random_seed current_collected_functional_coverage_percent: $total_functional_coverage_percent% [DISCARDED BY SEED_SELECTOR]" >> seeds.log
                   ((test_runs+=1))
                   rebuilds=0
                   continue
               ## If seed selector approves
               else
                   rebuilds=1
               fi
            fi
         else
            cd $CORE_V_VERIF/$project/sim/uvmt
            if [[ $current_test =~ corev* ]]
            then
               echo "Running test: [cd $CORE_V_VERIF/$project/sim/uvmt && make gen_corev-dv test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed SEED_SELECTOR=$seed_selector]"
               make gen_corev-dv test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed;
            else
               echo "Running test: [cd $CORE_V_VERIF/$project/sim/uvmt && make test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed SEED_SELECTOR=$seed_selector]"
               make test TEST=$current_test CV_CORE=$project CFG=$current_cfg COREV=1 SIMULATOR=$sim COMP=0 USE_ISS=NO COV=YES SEED=$random_seed;
            fi
         fi
         ((test_runs+=1))
         cp -r $regression_path/xrun_results/$current_cfg/$current_test/0/cov_work $current_test_run_path
         cp -r $regression_path/xrun_results/$current_cfg/$current_test/0/xrun-$current_test.log $current_test_run_path
         rm -rf $regression_path/xrun_results/$current_cfg/$current_test/

         cd $regression_path
         rm -rf automerge/ automerge.cmd autorunfile
         ${CORE_V_VERIF}/merge_cov
         imc -load ./automerge -execcmd "report -summary -metrics covergroup -cumulative on -local off" > merged_functional_coverage_summary.log
         ${CORE_V_VERIF}/cov_report_parsing.pl
         total_functional_coverage_percent=$?
         echo -e "$current_test_run random_seed: $random_seed current_collected_functional_coverage_percent: $total_functional_coverage_percent%" >> seeds.log
         echo -e "current_collected_functional_coverage_percent: $total_functional_coverage_percent%"
         echo -e "target_functional_coverage_percent           : $target_functional_coverage_percent%\n"
         imc -load ./automerge -execcmd "report -detail -inst uvm_pkg.uvm_test_top.env.cov_model.debug_covg -metrics covergroup -both" > merged_functional_coverage_detailed.log
         end_time=`date +%s%N`
         ${CORE_V_VERIF}/cov_report_parsing_coverpoints.pl
         echo -e "\nEND_TIME: $(($end_time / 1000))"
         echo -e "COVERPOINTS_TIME:" $(($end_time/1000 - $start_time/1000)) "s"
         if [ "$seed_selector" -ne 0 ]
         then
            #Updating tree coverage model
            echo -e "Creating base tree coverage model"
            ${CORE_V_VERIF}/create_tree_cov_model.pl > $regression_path/seed_selector/tree_cov_model_base.sv
            cp -v $regression_path/seed_selector/tree_cov_model_base.sv $current_test_run_path
            cp -v $regression_path/seed_selector/tree_cov_model_base.sv ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/
            echo -e "Base tree coverage model created\n"

            if [[ $(($total_functional_coverage_percent)) -ge $(($target_functional_coverage_percent)) ]] || [[ "$rebuilds" -eq 0 ]]
            then
               echo -e "No need to rerun builds\n"
            else
               echo -e "Rerunnig builds"
               case "$project" in
                  cv32e40p)
                     ## Build:corev-dv
                     echo "Rerunning build: [cd $CORE_V_VERIF/$project/sim/uvmt && make clean_riscv-dv comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make clean_riscv-dv comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0
                     popd > /dev/null
                     ## Build:uvmt_cv32e40p
                     echo "Rerunning build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES
                     popd > /dev/null

                     ;;
                  cv32e40x)
                     # Build:corev-dv
                     echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim COV=0
                     popd > /dev/null
                     # Build:uvmt_cv32e40x
                     echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make comp CV_CORE=$project CFG=default SIMULATOR=$sim COV=YES
                     popd > /dev/null

                     ;;
                  cv32e40s)
                     # Build:corev-dv
                     echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=0  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make comp_corev-dv CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=0
                     popd > /dev/null
                     # Build:uvmt_cv32e40s
                     echo "Running build: [cd $CORE_V_VERIF/$project/sim/uvmt && make comp CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=YES  ]"
                     pushd $CORE_V_VERIF/$project/sim/uvmt > /dev/null
                     make comp CV_CORE=$project CFG=default SIMULATOR=$sim USE_ISS=NO COV=YES
                     popd > /dev/null

                     ;;
               esac
               rebuilds=0
            fi
            cd $regression_path
         fi
      done
      if [ "$seed_selector" -ne 0 ]
      then
         echo -e "Removing the repo's tree_cov_model_base.v file"
         rm -rf ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/tree_cov_model_base.sv
         echo -e "Restoring the repo's tree_cov_model_base.v file"
         echo -e "\`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\nfunction int build_base_covmodel_tree(int influence_param_1);\n\n\t\$display(\"SEED_SELECTOR: First test run, no coverage tree yet.\");\n\nendfunction" > ${CORE_V_VERIF}/$project/tests/uvmt/base-tests/seed_selector/tree_cov_model_base.sv
      fi
      rm -rf $regression_path/xrun_results/
      rm -rf $CORE_V_VERIF/bin/lib/__pycache__/
	   rm -rf $CORE_V_VERIF/$project/vendor_lib/verilab/svlib/
      echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
      echo -e " ╔╦╗╔═╗╔╦╗╔═╗╦    ╦═╗╔═╗╔═╗╦═╗╔═╗╔═╗╔═╗╦╔═╗╔╗╔  ╔╦╗╦╔╦╗╔═╗"
      echo -e "  ║ ║ ║ ║ ╠═╣║    ╠╦╝║╣ ║ ╦╠╦╝║╣ ╚═╗╚═╗║║ ║║║║   ║ ║║║║║╣ "
      echo -e "  ╩ ╚═╝ ╩ ╩ ╩╩═╝  ╩╚═╚═╝╚═╝╩╚═╚═╝╚═╝╚═╝╩╚═╝╝╚╝   ╩ ╩╩ ╩╚═╝"
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
   }
}

#-----------------------------------------------------------------
#-----------------------------------------------------------------
#Set these variables first
regressions_folder="/nis/asic/cr_dump2/fallasad/SeedSelector_Ubuntu/CoreV_RegressionResults_CV32E40P"
#-----------------------------------------------------------------
#-----------------------------------------------------------------

mkdir -p $regressions_folder

regression_name="$project"__`date +"%Y_%m_%d__%H_%M_%S"`
regression_path="$regressions_folder"/"$regression_name"
mkdir $regression_path
export CV_RESULTS=$regression_path
main 2>&1 | tee -a $regression_path/regression.log
