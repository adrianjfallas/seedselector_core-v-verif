///////////////////////////////////////////////////////////////////////////////
// Copyright 2020 OpenHW Group
// Copyright 2020 BTA Design Services
// Copyright 2020 Silicon Labs, Inc.
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://solderpad.org/licenses/
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
//
///////////////////////////////////////////////////////////////////////////////

`ifndef SEED_SELECTOR
   `define SEED_SELECTOR 0
`endif

class uvme_debug_covg extends uvm_component;

    /*
    * Class members
    */
    uvme_cv32e40p_cntxt_c  cntxt;


    `uvm_component_utils(uvme_debug_covg);

    extern function new(string name = "debug_covg", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    extern task sample_clk_i();
    extern task sample_debug_req_i();

    /*
    * Covergroups
    */

  covergroup cg_debug_mode_ext ;
          `per_instance_fcov
          state: coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs{
              ignore_bins ignore_pulp_states = {cv32e40p_pkg::ELW_EXE, cv32e40p_pkg::IRQ_FLUSH_ELW, cv32e40p_pkg::DECODE_HWLOOP};
          }
  endgroup : cg_debug_mode_ext

  // Waive duplicate code since embedded covergroups are used
  //@DVT_LINTER_WAIVER_START "SR20211012_1" disable SVTB.33.1.0

  // Cover that we execute ebreak with dcsr.ebreakm==1
  covergroup cg_ebreak_execute_with_ebreakm;
          `per_instance_fcov
          ex: coverpoint cntxt.debug_cov_vif.mon_cb.is_ebreak {
                  bins active = {1};
          }
          ebreakm_set: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[15] {
                  bins active = {1};
          }
          dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
                  bins active = {1};
          }
          ebreak_with_ebreakm: cross ex, ebreakm_set;
          ebreak_in_debug : cross ex, dm;
  endgroup

  // Cover that we execute c.ebreak with dcsr.ebreakm==1
  covergroup cg_cebreak_execute_with_ebreakm;
          `per_instance_fcov
          ex: coverpoint cntxt.debug_cov_vif.mon_cb.is_cebreak {
                  bins active = {1};
          }
          ebreakm_set: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[15] {
                  bins active = {1};
          }
          dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
                  bins active = {1};
          }
          cebreak_with_ebreakm: cross ex, ebreakm_set;
          cebreak_in_debug : cross ex, dm;
  endgroup

  // Cover that we execute ebreak with dcsr.ebreakm==0
  covergroup cg_ebreak_execute_without_ebreakm;
          `per_instance_fcov
          ex: coverpoint cntxt.debug_cov_vif.mon_cb.is_ebreak {
                  bins active = {1};
          }
          ebreakm_clear: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[15] {
                  bins active = {0};
          }
          step: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
                  bins active = {1};
          }
          nostep: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
                  bins active = {0};
          }
          ebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;
          ebreak_step_nodebug : cross ex, ebreakm_clear, step;
  endgroup

  // Cover that we execute c.ebreak with dcsr.ebreakm==0
  covergroup cg_cebreak_execute_without_ebreakm;
          `per_instance_fcov
          ex: coverpoint cntxt.debug_cov_vif.mon_cb.is_cebreak {
                  bins active = {1};
          }
          ebreakm_clear: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[15] {
                  bins active = {0};
          }
          step: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
                  bins active = {1};
          }
          nostep: coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
                  bins active = {0};
          }
          cebreak_regular_nodebug: cross ex, ebreakm_clear, nostep;
          cebreak_step_nodebug : cross ex, ebreakm_clear, step;
  endgroup
  //@DVT_LINTER_WAIVER_END "SR20211012_1"

    // Cover that we hit a trigger match
    covergroup cg_trigger_match;
        `per_instance_fcov
        en : coverpoint cntxt.debug_cov_vif.mon_cb.tdata1[2] {
            bins active = {1};
        }
        match: coverpoint cntxt.debug_cov_vif.mon_cb.trigger_match_i {
            bins hit = {1};
        }
        ok_match: cross en, match;
    endgroup

    // cover that we hit pc==tdata2  without having enabled trigger in m/d-mode
    // cover hit in d-mode with trigger enabled (no action)
    covergroup cg_trigger_match_disabled;
        `per_instance_fcov
        dis : coverpoint cntxt.debug_cov_vif.mon_cb.tdata1[2] {
            bins hit = {0};
        }
        en : coverpoint cntxt.debug_cov_vif.mon_cb.tdata1[2] {
            bins hit = {1};
        }
        match: coverpoint cntxt.debug_cov_vif.mon_cb.addr_match {
           bins hit = {1};
        }
        mmode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
           bins m = {0};
        }
        dmode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
           bins m = {1};
        }
        m_match_without_en : cross dis, match, mmode;
        d_match_without_en : cross dis, match, dmode;
        d_match_with_en    : cross en, match, dmode;
    endgroup

    // Cover that we hit an exception during debug mode
    covergroup cg_debug_mode_exception;
        `per_instance_fcov
        dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins hit  = {1};
        }
        ill : coverpoint cntxt.debug_cov_vif.mon_cb.illegal_insn_q {
            bins hit = {1};
        }
        ex_in_debug : cross dm, ill;
    endgroup

    // Cover that we hit an ecall during debug mode
    covergroup cg_debug_mode_ecall;
        `per_instance_fcov
        dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins hit  = {1};
        }
        ill : coverpoint cntxt.debug_cov_vif.mon_cb.ecall_insn_i {
            bins hit = {1};
        }
        ex_in_debug : cross dm, ill;
    endgroup

    // Cover that we get interrupts while in debug mode
    covergroup cg_irq_in_debug;
        `per_instance_fcov
        dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins hit  = {1};
        }
        irq : coverpoint |cntxt.debug_cov_vif.mon_cb.irq_i {
            bins hit = {1};
        }
        ex_in_debug : cross dm, irq;
    endgroup

    // Cover that hit a WFI insn in debug mode
    covergroup cg_wfi_in_debug;
        `per_instance_fcov
        iswfi : coverpoint cntxt.debug_cov_vif.mon_cb.is_wfi {
                bins hit  = {1};
        }
        dm : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins hit = {1};
        }
        dm_wfi : cross iswfi, dm;
    endgroup

    // Cover that we get a debug_req while in wfi
    covergroup cg_wfi_debug_req;
        `per_instance_fcov
        inwfi : coverpoint cntxt.debug_cov_vif.mon_cb.in_wfi {
                bins hit  = {1};
        }
        dreq: coverpoint cntxt.debug_cov_vif.mon_cb.debug_req_i {
            bins hit = {1};
        }
        dm_wfi : cross inwfi, dreq;
    endgroup

    // Cover that we perform single stepping
    covergroup cg_single_step;
        `per_instance_fcov
        step : coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] {
                bins en  = {1};
        }
        mmode: coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins hit = {0};
        }
        trigger : coverpoint cntxt.debug_cov_vif.mon_cb.trigger_match_i {
            bins hit = {1};
        }
        wfi : coverpoint cntxt.debug_cov_vif.mon_cb.is_wfi {
            bins hit = {1};
        }
        ill : coverpoint cntxt.debug_cov_vif.mon_cb.illegal_insn_i {
            bins hit = {1};
        }
        pc_will_trig : coverpoint cntxt.debug_cov_vif.mon_cb.dpc_will_hit {
            bins hit = {1};
        }
        stepie : coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[11];
        mmode_step : cross step, mmode;
        mmode_step_trigger_match : cross step, mmode, trigger;
        mmode_step_wfi : cross step, mmode, wfi;
        mmode_step_stepie : cross step, mmode, stepie;
        mmode_step_illegal : cross step, mmode, ill;
        mmode_step_next_pc_will_match : cross step, mmode, pc_will_trig;
    endgroup

    // Cover dret is executed in machine mode
    covergroup cg_mmode_dret;
        `per_instance_fcov
        mmode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q;
        dret_ins : coverpoint cntxt.debug_cov_vif.mon_cb.is_dret {
            bins hit = {1};
        }
        dret_ex : cross mmode, dret_ins;
    endgroup

    // Cover debug_req and irq asserted on same cycle
    covergroup cg_irq_dreq;
        `per_instance_fcov
        dreq : coverpoint cntxt.debug_cov_vif.mon_cb.debug_req_i {
                bins trans_active  = (1'b0 => 1'b1);
        }
        irq  : coverpoint |cntxt.debug_cov_vif.mon_cb.irq_i {
                bins trans_active = (1'b0 => 1'b1);
        }
        trigger : coverpoint cntxt.debug_cov_vif.mon_cb.trigger_match_i {
            bins hit = {1};
        }
        ill : coverpoint cntxt.debug_cov_vif.mon_cb.illegal_insn_i {
            bins hit = {1};
        }
         ebreak : coverpoint cntxt.debug_cov_vif.mon_cb.is_ebreak {
            bins active= {1'b1};
        }
         cebreak : coverpoint cntxt.debug_cov_vif.mon_cb.is_cebreak {
            bins active= {1'b1};
        }
         branch : coverpoint cntxt.debug_cov_vif.mon_cb.branch_in_decode {
            bins active= {1'b1};
        }
         mulhsu : coverpoint cntxt.debug_cov_vif.mon_cb.is_mulhsu {
            bins active= {1'b1};
        }
        dreq_and_ill : cross dreq, ill;
        irq_and_dreq : cross dreq, irq;
        irq_dreq_trig_ill : cross dreq, irq, trigger, ill;
        irq_dreq_trig_cebreak : cross dreq, irq, trigger, cebreak;
        irq_dreq_trig_ebreak : cross dreq, irq, trigger, ebreak;
        irq_dreq_trig_branch : cross dreq, irq, trigger, branch;
        irq_dreq_trig_multicycle : cross dreq, irq, trigger, mulhsu;
    endgroup

    // Cover access to dcsr, dpc and dscratch0/1 in D-mode
    covergroup cg_debug_regs_d_mode;
        `per_instance_fcov
        mode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins M = {1} ;
        }

        access : coverpoint cntxt.debug_cov_vif.mon_cb.csr_access {
            bins hit = {1};
        }
        op : coverpoint cntxt.debug_cov_vif.mon_cb.csr_op {
            bins read = {'h0};
            bins write = {'h1};
        }
        addr  : coverpoint cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] { // csr addr not updated if illegal access
            bins dcsr = {'h7B0};
            bins dpc = {'h7B1};
            bins dscratch0 = {'h7B2};
            bins dscratch1 = {'h7B3};
        }
        dregs_access : cross mode, access, op,addr;
    endgroup

    // Cover access to dcsr, dpc and dscratch0/1 in M-mode
    covergroup cg_debug_regs_m_mode;
        `per_instance_fcov
        mode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins M = {0} ;
        }

        access : coverpoint cntxt.debug_cov_vif.mon_cb.csr_access {
            bins hit = {1};
        }
        op : coverpoint cntxt.debug_cov_vif.mon_cb.csr_op_dec {
            bins read = {1'h0};
            bins write = {1'h1};
        }
        addr  : coverpoint cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] { // csr addr not updated if illegal access
            bins dcsr = {'h7B0};
            bins dpc = {'h7B1};
            bins dscratch0 = {'h7B2};
            bins dscratch1 = {'h7B3};
        }
        dregs_access : cross mode, access, op,addr;
    endgroup
    // Cover access to trigger registers
    // Do we need to cover all READ/WRITE/SET/CLEAR from m-mode?
    covergroup cg_trigger_regs;
        `per_instance_fcov
        mode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q; // Only M and D supported
        access : coverpoint cntxt.debug_cov_vif.mon_cb.csr_access {
            bins hit = {1};
        }
        op : coverpoint cntxt.debug_cov_vif.mon_cb.csr_op {
            bins read = {'h0};
            bins write = {'h1};
        }
        addr  : coverpoint cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20]{ // csr addr not updated if illegal access
            bins tsel = {'h7A0};
            bins tdata1 = {'h7A1};
            bins tdata2 = {'h7A2};
            bins tdata3 = {'h7A3};
            bins tinfo  = {'h7A4};
        }
        tregs_access : cross mode, access, op,addr;
    endgroup

    // Cover that we run with counters mcycle and minstret enabled
    covergroup cg_counters_enabled;
        `per_instance_fcov
        mcycle_en : coverpoint cntxt.debug_cov_vif.mon_cb.mcountinhibit_q[0];
        minstret_en : coverpoint cntxt.debug_cov_vif.mon_cb.mcountinhibit_q[2];
    endgroup

    // Cover that we get a debug_req_i while in RESET state
    covergroup cg_debug_at_reset;
        `per_instance_fcov
        state : coverpoint cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs {
            bins reset= {cv32e40p_pkg::RESET};
        }
         dbg : coverpoint cntxt.debug_cov_vif.mon_cb.debug_req_i {
            bins active= {1'b1};
        }
        dbg_at_reset : cross state, dbg;
    endgroup

    // Cover that we execute fence and fence.i in debug mode
    covergroup cg_fence_in_debug;
        `per_instance_fcov
        mode : coverpoint cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins debug= {1'b1};
        }
        fence : coverpoint cntxt.debug_cov_vif.mon_cb.fence_i {
            bins active= {1'b1};
        }
        fence_in_debug : cross mode, fence;
    endgroup

    // Cover that we get all combinations of debug causes
    covergroup cg_debug_causes;
        `per_instance_fcov
        tmatch : coverpoint cntxt.debug_cov_vif.mon_cb.trigger_match_i {
            bins match= {1'b1};
        }
        tnomatch : coverpoint cntxt.debug_cov_vif.mon_cb.trigger_match_i {
            bins nomatch= {1'b0};
        }
         ebreak : coverpoint cntxt.debug_cov_vif.mon_cb.is_ebreak {
            bins active= {1'b1};
        }
         cebreak : coverpoint cntxt.debug_cov_vif.mon_cb.is_cebreak {
            bins active= {1'b1};
        }
         dbg_req : coverpoint cntxt.debug_cov_vif.mon_cb.debug_req_i {
            bins active= {1'b1};
        }
         step : coverpoint cntxt.debug_cov_vif.mon_cb.dcsr_q[2] & !cntxt.debug_cov_vif.mon_cb.debug_mode_q {
            bins active= {1'b1};
        }
        trig_vs_ebreak : cross tmatch, ebreak;
        trig_vs_cebreak : cross tmatch, cebreak;
        trig_vs_dbg_req : cross tmatch, dbg_req;
        trig_vs_step : cross tmatch, step;
        // Excluding trigger match to check 'lower' priority causes
        ebreak_vs_req : cross ebreak, dbg_req, tnomatch;
        cebreak_vs_req : cross cebreak, dbg_req, tnomatch;
        ebreak_vs_step : cross ebreak, step;
        cebreak_cs_step : cross cebreak, step;
        dbg_req_vs_step : cross dbg_req, step;
    endgroup

endclass : uvme_debug_covg

function uvme_debug_covg::new(string name = "debug_covg", uvm_component parent = null);
    super.new(name, parent);

    cg_debug_mode_ext = new();
    cg_ebreak_execute_with_ebreakm = new();
    cg_cebreak_execute_with_ebreakm = new();
    cg_ebreak_execute_without_ebreakm = new();
    cg_cebreak_execute_without_ebreakm = new();
    cg_trigger_match = new();
    cg_trigger_match_disabled = new();
    cg_debug_mode_exception = new();
    cg_debug_mode_ecall = new();
    cg_irq_in_debug = new();
    cg_wfi_in_debug = new();
    cg_wfi_debug_req = new();
    cg_single_step = new();
    cg_mmode_dret = new();
    cg_irq_dreq = new();
    cg_debug_regs_d_mode = new();
    cg_debug_regs_m_mode = new();
    cg_trigger_regs = new();
    cg_counters_enabled = new();
    cg_debug_at_reset = new();
    cg_fence_in_debug = new();
    cg_debug_causes = new();
endfunction : new

function void uvme_debug_covg::build_phase(uvm_phase phase);
    super.build_phase(phase);

    void'(uvm_config_db#(uvme_cv32e40p_cntxt_c)::get(this, "", "cntxt", cntxt));
    if (cntxt == null) begin
        `uvm_fatal("DEBUGCOVG", "No cntxt object passed to model");
    end
endfunction : build_phase

task uvme_debug_covg::run_phase(uvm_phase phase);
    super.run_phase(phase);

    `uvm_info("DEBUGCOVG", "The debug coverage model is running", UVM_LOW);

    fork
        sample_debug_req_i();
        sample_clk_i();
    join_none
endtask : run_phase

task uvme_debug_covg::sample_debug_req_i();

  //string debug_mode_state_val = "NEITHER";

  while(1) begin
    @(posedge cntxt.debug_cov_vif.mon_cb.debug_req_i);

    //if(`SEED_SELECTOR == 1) begin
      //if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::RESET) begin
      //   debug_mode_state_val = "RESET";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::BOOT_SET) begin
      //   debug_mode_state_val = "BOOT_SET";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::SLEEP) begin
      //   debug_mode_state_val = "SLEEP";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::WAIT_SLEEP) begin
      //   debug_mode_state_val = "WAIT_SLEEP";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::FIRST_FETCH) begin
      //   debug_mode_state_val = "FIRST_FETCH";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::DECODE) begin
      //   debug_mode_state_val = "DECODE";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::FLUSH_EX) begin
      //   debug_mode_state_val = "FLUSH_EX";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::FLUSH_WB) begin
      //   debug_mode_state_val = "FLUSH_WB";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::XRET_JUMP) begin
      //   debug_mode_state_val = "XRET_JUMP";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::DBG_TAKEN_ID) begin
      //   debug_mode_state_val = "DBG_TAKEN_ID";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::DBG_TAKEN_IF) begin
      //   debug_mode_state_val = "DBG_TAKEN_IF";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::DBG_FLUSH) begin
      //   debug_mode_state_val = "DBG_FLUSH";
      //end else if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::DBG_WAIT_BRANCH) begin
      //   debug_mode_state_val = "DBG_WAIT_BRANCH";
      //end
      //`uvm_info("DEBUG_COVG",$psprintf("-------------------------------------------------------------------------------"), UVM_LOW)
      //`uvm_info("DEBUG_COVG",$psprintf("##############  cg_debug_mode_ext  ##############"), UVM_LOW)
      //`uvm_info("DEBUG_COVG",$psprintf("state                : %s", debug_mode_state_val), UVM_LOW)

      //`uvm_info("DEBUGCOVG",$psprintf("SEED_SELECTOR1: ANALYZING SEED"), UVM_LOW)
      //`uvm_info("DEBUGCOVG",$psprintf("SEED_SELECTOR1: APPROVED"), UVM_LOW)
      //`uvm_fatal(get_type_name(), "SEED_SELECTOR: DISCARDED")
      //`include "seed_selector/seed_selector.sv"
      //`uvm_info("DEBUGCOVG", "HERE I AM1", UVM_LOW);
    //end

    cg_debug_mode_ext.sample();
  end
endtask : sample_debug_req_i

task uvme_debug_covg::sample_clk_i();

  //int cebreak_val = 0;
  //int ebreakm_set_val = 0;
  //int debug_mode_q_val = 0;
  //int machine_mode_q_val = 0;
  //int cebreak_with_ebreakm_val = 0;
  //int cebreak_in_debug_val = 0;
  //int ebreak_val = 0;
  //int ebreak_with_ebreakm_val = 0;
  //int ebreak_in_debug_val = 0;
  //int ebreakm_clear_val = 0;
  //int step_val = 0;
  //int no_step_val = 0;
  //int step_no_dbg_val = 0;
  //int ebreak_regular_nodebug_val = 0;
  //int ebreak_step_nodebug_val = 0;
  //int cebreak_regular_nodebug_val = 0;
  //int cebreak_step_nodebug_val = 0;
  //int trigger_val = 0;
  //int trigger_dis_val = 0;
  //int trigger_match_val = 0;
  //int trigger_no_match_val = 0;
  //int ok_match_val = 0;
  //int addr_match_val = 0;
  //int m_match_without_en_val = 0;
  //int d_match_without_en_val = 0;
  //int d_match_with_en_val = 0;
  //int illegal_insn_q_val = 0;
  //int ex_in_debug_illegal_val = 0;
  //int ecall_insn_i_val = 0;
  //int ex_in_debug_ecall_val = 0;
  //int irq_i_val = 0;
  //int prev_irq_i_val = 0;
  //int irq_i_trans_val = 0;
  //int ex_in_debug_irq_val = 0;
  //int is_wfi_val = 0;
  //int dm_wfi_debug_val = 0;
  //int in_wfi_val = 0;
  //int debug_req_i_val = 0;
  //int prev_debug_req_i_val = 0;
  //int debug_req_i_trans_val = 0;
  //int dm_wfi_req_val = 0;
  //int illegal_insn_i_val = 0;
  //int dpc_will_hit_val = 0;
  //int stepie_val = 0;
  //int mmode_step_val = 0;
  //int mmode_step_trigger_match_val = 0;
  //int mmode_step_wfi_val = 0;
  //int mmode_step_stepie_val = 0;
  //int mmode_step_illegal_val = 0;
  //int mmode_step_next_pc_will_match_val = 0;
  //int is_dret_val = 0;
  //int dret_ex_val = 0;
  //int branch_in_decode_val = 0;
  //int is_mulhsu_val = 0;
  //int dreq_and_ill_val = 0;
  //int irq_and_dreq_val = 0;
  //int irq_dreq_trig_ill_val = 0;
  //int irq_dreq_trig_cebreak_val = 0;
  //int irq_dreq_trig_ebreak_val = 0;
  //int irq_dreq_trig_branch_val = 0;
  //int irq_dreq_trig_multicycle_val = 0;
  //int csr_access_val = 0;
  //int op_read_val = 0;
  //int op_write_val = 0;
  //int addr_dcsr_val = 0;
  //int addr_dpc_val = 0;
  //int addr_dscratch0_val = 0;
  //int addr_dscratch1_val = 0;
  //int d_dres_access0_val = 0;
  //int d_dres_access1_val = 0;
  //int d_dres_access2_val = 0;
  //int d_dres_access3_val = 0;
  //int d_dres_access4_val = 0;
  //int d_dres_access5_val = 0;
  //int d_dres_access6_val = 0;
  //int d_dres_access7_val = 0;
  //int m_dres_access0_val = 0;
  //int m_dres_access1_val = 0;
  //int m_dres_access2_val = 0;
  //int m_dres_access3_val = 0;
  //int m_dres_access4_val = 0;
  //int m_dres_access5_val = 0;
  //int m_dres_access6_val = 0;
  //int m_dres_access7_val = 0;
  //int addr_trigger_regs0_val = 0;
  //int addr_trigger_regs1_val = 0;
  //int addr_trigger_regs2_val = 0;
  //int addr_trigger_regs3_val = 0;
  //int addr_trigger_regs4_val = 0;
  //int tregs_access0_val = 0;
  //int tregs_access1_val = 0;
  //int tregs_access2_val = 0;
  //int tregs_access3_val = 0;
  //int tregs_access4_val = 0;
  //int tregs_access5_val = 0;
  //int tregs_access6_val = 0;
  //int tregs_access7_val = 0;
  //int tregs_access8_val = 0;
  //int tregs_access9_val = 0;
  //int mcycle_en_val = 0;
  //int minstret_en_val = 0;
  //int state_reset_val = 0;
  //int dbg_at_reset_val = 0;
  //int fence_i_val = 0;
  //int fence_in_debug_val = 0;
  //int trig_vs_ebreak_val = 0;
  //int trig_vs_cebreak_val = 0;
  //int trig_vs_dbg_req_val = 0;
  //int trig_vs_step_val = 0;
  //int ebreak_vs_req_val = 0;
  //int cebreak_vs_req_val = 0;
  //int ebreak_vs_step_val = 0;
  //int cebreak_cs_step_val = 0;
  //int dbg_req_vs_step_val = 0;

  while (1) begin
    @(cntxt.debug_cov_vif.mon_cb);

    //if(`SEED_SELECTOR == 1) begin
        //if(cntxt.debug_cov_vif.mon_cb.is_cebreak) begin cebreak_val = 1; end else begin cebreak_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) begin ebreakm_set_val = 1; ebreakm_clear_val = 0; end else begin ebreakm_set_val = 0; ebreakm_clear_val = 1; end
        //if(cntxt.debug_cov_vif.mon_cb.debug_mode_q) begin debug_mode_q_val = 1; machine_mode_q_val = 0; end else begin debug_mode_q_val = 0; machine_mode_q_val = 1; end
        //if(cntxt.debug_cov_vif.mon_cb.is_cebreak && cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) begin cebreak_with_ebreakm_val = 1; end else begin cebreak_with_ebreakm_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_cebreak && cntxt.debug_cov_vif.mon_cb.debug_mode_q) begin cebreak_in_debug_val = 1; end else begin cebreak_in_debug_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_ebreak) begin ebreak_val = 1; end else begin ebreak_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_ebreak && cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) begin ebreak_with_ebreakm_val = 1; end else begin ebreak_with_ebreakm_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_ebreak && cntxt.debug_cov_vif.mon_cb.debug_mode_q) begin ebreak_in_debug_val = 1; end else begin ebreak_in_debug_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) begin step_val = 1; no_step_val = 0; end else begin step_val = 0; no_step_val = 1; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin step_no_dbg_val = 1; end else begin step_no_dbg_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.is_ebreak) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[2])) begin ebreak_regular_nodebug_val = 1; end else begin ebreak_regular_nodebug_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.is_ebreak) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) && (cntxt.debug_cov_vif.mon_cb.dcsr_q[2])) begin ebreak_step_nodebug_val = 1; end else begin ebreak_step_nodebug_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.is_cebreak) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[2])) begin cebreak_regular_nodebug_val = 1; end else begin cebreak_regular_nodebug_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.is_cebreak) && !(cntxt.debug_cov_vif.mon_cb.dcsr_q[15]) && (cntxt.debug_cov_vif.mon_cb.dcsr_q[2])) begin cebreak_step_nodebug_val = 1; end else begin cebreak_step_nodebug_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.tdata1[2]) begin trigger_val = 1; trigger_dis_val = 0; end else begin trigger_val = 0; trigger_dis_val = 1; end
        //if(cntxt.debug_cov_vif.mon_cb.trigger_match_i) begin trigger_match_val = 1; end else begin trigger_match_val = 0; end
        //if(!(cntxt.debug_cov_vif.mon_cb.trigger_match_i)) begin trigger_no_match_val = 1; end else begin trigger_no_match_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.tdata1[2]) && (cntxt.debug_cov_vif.mon_cb.trigger_match_i)) begin ok_match_val = 1; end else begin ok_match_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.addr_match) begin addr_match_val = 1; end else begin addr_match_val = 0; end
        //if(!(cntxt.debug_cov_vif.mon_cb.tdata1[2]) && (cntxt.debug_cov_vif.mon_cb.addr_match) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin m_match_without_en_val = 1; end else begin m_match_without_en_val = 0; end
        //if(!(cntxt.debug_cov_vif.mon_cb.tdata1[2]) && (cntxt.debug_cov_vif.mon_cb.addr_match) && (cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin d_match_without_en_val = 1; end else begin d_match_without_en_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.tdata1[2]) && (cntxt.debug_cov_vif.mon_cb.addr_match) && (cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin d_match_with_en_val = 1; end else begin d_match_with_en_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.illegal_insn_q) begin illegal_insn_q_val = 1; end else begin illegal_insn_q_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.illegal_insn_q)) begin ex_in_debug_illegal_val = 1; end else begin ex_in_debug_illegal_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.ecall_insn_i) begin ecall_insn_i_val = 1; end else begin ecall_insn_i_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.ecall_insn_i)) begin ex_in_debug_ecall_val = 1; end else begin ex_in_debug_ecall_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.irq_i) begin irq_i_val = 1; end else begin irq_i_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.irq_i)) begin ex_in_debug_irq_val = 1; end else begin ex_in_debug_irq_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_wfi) begin is_wfi_val = 1; end else begin is_wfi_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.is_wfi) && (cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin dm_wfi_debug_val = 1; end else begin dm_wfi_debug_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.in_wfi) begin in_wfi_val = 1; end else begin in_wfi_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.debug_req_i) begin debug_req_i_val = 1; end else begin debug_req_i_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.in_wfi) && (cntxt.debug_cov_vif.mon_cb.debug_req_i)) begin dm_wfi_req_val = 1; end else begin dm_wfi_req_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.illegal_insn_i) begin illegal_insn_i_val = 1; end else begin illegal_insn_i_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.dpc_will_hit) begin dpc_will_hit_val = 1; end else begin dpc_will_hit_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.dcsr_q[11]) begin stepie_val = 1; end else begin stepie_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q)) begin mmode_step_val = 1; end else begin mmode_step_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.trigger_match_i)) begin mmode_step_trigger_match_val = 1; end else begin mmode_step_trigger_match_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.is_wfi)) begin mmode_step_wfi_val = 1; end else begin mmode_step_wfi_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.dcsr_q[11])) begin mmode_step_stepie_val = 1; end else begin mmode_step_stepie_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.illegal_insn_i)) begin mmode_step_illegal_val = 1; end else begin mmode_step_illegal_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.dcsr_q[2]) && !(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.dpc_will_hit)) begin mmode_step_next_pc_will_match_val = 1; end else begin mmode_step_next_pc_will_match_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_dret) begin is_dret_val = 1; end else begin is_dret_val = 0; end
        //if(!(cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.is_dret)) begin dret_ex_val = 1; end else begin dret_ex_val = 0; end
        //if((prev_debug_req_i_val == 0) && (debug_req_i_val == 1)) begin debug_req_i_trans_val = 1; end else begin debug_req_i_trans_val = 0; end
        //if((prev_irq_i_val == 0) && (irq_i_val)) begin irq_i_trans_val = 1; end else begin irq_i_trans_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.branch_in_decode) begin branch_in_decode_val = 1; end else begin branch_in_decode_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.is_mulhsu) begin is_mulhsu_val = 1; end else begin is_mulhsu_val = 0; end
        //if((debug_req_i_trans_val == 1) && (illegal_insn_i_val == 1)) begin dreq_and_ill_val = 1; end else begin dreq_and_ill_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1)) begin irq_and_dreq_val = 1; end else begin irq_and_dreq_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1) && (trigger_match_val == 1) && (illegal_insn_i_val == 1)) begin irq_dreq_trig_ill_val = 1; end else begin irq_dreq_trig_ill_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1) && (trigger_match_val == 1) && (cebreak_val == 1)) begin irq_dreq_trig_cebreak_val = 1; end else begin irq_dreq_trig_cebreak_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1) && (trigger_match_val == 1) && (ebreak_val == 1)) begin irq_dreq_trig_ebreak_val = 1; end else begin irq_dreq_trig_ebreak_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1) && (trigger_match_val == 1) && (branch_in_decode_val == 1)) begin irq_dreq_trig_branch_val = 1; end else begin irq_dreq_trig_branch_val = 0; end
        //if((irq_i_trans_val == 1) && (debug_req_i_trans_val == 1) && (trigger_match_val == 1) && (is_mulhsu_val == 1)) begin irq_dreq_trig_multicycle_val = 1; end else begin irq_dreq_trig_multicycle_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.csr_access) begin csr_access_val = 1; end else begin csr_access_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.csr_op) begin op_read_val = 0; op_write_val = 1; end else begin op_read_val = 1; op_write_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7B0) begin addr_dcsr_val = 1; end else begin addr_dcsr_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7B1) begin addr_dpc_val = 1; end else begin addr_dpc_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7B2) begin addr_dscratch0_val = 1; end else begin addr_dscratch0_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7B3) begin addr_dscratch1_val = 1; end else begin addr_dscratch1_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dcsr_val == 1)) begin d_dres_access0_val = 1; end else begin d_dres_access0_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dpc_val == 1)) begin d_dres_access1_val = 1; end else begin d_dres_access1_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dscratch0_val == 1)) begin d_dres_access2_val = 1; end else begin d_dres_access2_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dscratch1_val == 1)) begin d_dres_access3_val = 1; end else begin d_dres_access3_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dcsr_val == 1)) begin d_dres_access4_val = 1; end else begin d_dres_access4_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dpc_val == 1)) begin d_dres_access5_val = 1; end else begin d_dres_access5_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dscratch0_val == 1)) begin d_dres_access6_val = 1; end else begin d_dres_access6_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dscratch1_val == 1)) begin d_dres_access7_val = 1; end else begin d_dres_access7_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dcsr_val == 1)) begin m_dres_access0_val = 1; end else begin m_dres_access0_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dpc_val == 1)) begin m_dres_access1_val = 1; end else begin m_dres_access1_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dscratch0_val == 1)) begin m_dres_access2_val = 1; end else begin m_dres_access2_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_dscratch1_val == 1)) begin m_dres_access3_val = 1; end else begin m_dres_access3_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dcsr_val == 1)) begin m_dres_access4_val = 1; end else begin m_dres_access4_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dpc_val == 1)) begin m_dres_access5_val = 1; end else begin m_dres_access5_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dscratch0_val == 1)) begin m_dres_access6_val = 1; end else begin m_dres_access6_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_dscratch1_val == 1)) begin m_dres_access7_val = 1; end else begin m_dres_access7_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7A0) begin addr_trigger_regs0_val = 1; end else begin addr_trigger_regs0_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7A1) begin addr_trigger_regs1_val = 1; end else begin addr_trigger_regs1_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7A2) begin addr_trigger_regs2_val = 1; end else begin addr_trigger_regs2_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7A3) begin addr_trigger_regs3_val = 1; end else begin addr_trigger_regs3_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.id_stage_instr_rdata_i[31:20] == 'h7A4) begin addr_trigger_regs4_val = 1; end else begin addr_trigger_regs4_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_trigger_regs0_val == 1)) begin tregs_access0_val = 1; end else begin tregs_access0_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_trigger_regs1_val == 1)) begin tregs_access1_val = 1; end else begin tregs_access1_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_trigger_regs2_val == 1)) begin tregs_access2_val = 1; end else begin tregs_access2_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_trigger_regs3_val == 1)) begin tregs_access3_val = 1; end else begin tregs_access3_val = 0; end
        //if((machine_mode_q_val == 1) && (csr_access_val == 1) && (op_read_val == 1) && (addr_trigger_regs4_val == 1)) begin tregs_access4_val = 1; end else begin tregs_access4_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_trigger_regs0_val == 1)) begin tregs_access5_val = 1; end else begin tregs_access5_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_trigger_regs1_val == 1)) begin tregs_access6_val = 1; end else begin tregs_access6_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_trigger_regs2_val == 1)) begin tregs_access7_val = 1; end else begin tregs_access7_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_trigger_regs3_val == 1)) begin tregs_access8_val = 1; end else begin tregs_access8_val = 0; end
        //if((debug_mode_q_val == 1) && (csr_access_val == 1) && (op_write_val == 1) && (addr_trigger_regs4_val == 1)) begin tregs_access9_val = 1; end else begin tregs_access9_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.mcountinhibit_q[0]) begin mcycle_en_val = 1; end else begin mcycle_en_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.mcountinhibit_q[2]) begin minstret_en_val = 1; end else begin minstret_en_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::RESET) begin state_reset_val = 1; end else begin state_reset_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.ctrl_fsm_cs == cv32e40p_pkg::RESET) && (cntxt.debug_cov_vif.mon_cb.debug_req_i)) begin dbg_at_reset_val = 1; end else begin dbg_at_reset_val = 0; end
        //if(cntxt.debug_cov_vif.mon_cb.fence_i) begin fence_i_val = 1; end else begin fence_i_val = 0; end
        //if((cntxt.debug_cov_vif.mon_cb.debug_mode_q) && (cntxt.debug_cov_vif.mon_cb.fence_i)) begin fence_in_debug_val = 1; end else begin fence_in_debug_val = 0; end
        //if((trigger_match_val == 1) && (ebreak_val == 1)) begin trig_vs_ebreak_val = 1; end else begin trig_vs_ebreak_val = 0; end
        //if((trigger_match_val == 1) && (cebreak_val == 1)) begin trig_vs_cebreak_val = 1; end else begin trig_vs_cebreak_val = 0; end
        //if((trigger_match_val == 1) && (debug_req_i_val == 1)) begin trig_vs_dbg_req_val = 1; end else begin trig_vs_dbg_req_val = 0; end
        //if((trigger_match_val == 1) && (step_no_dbg_val == 1)) begin trig_vs_step_val = 1; end else begin trig_vs_step_val = 0; end
        //if((trigger_no_match_val == 1) && (ebreak_val == 1) && (debug_req_i_val == 1)) begin ebreak_vs_req_val = 1; end else begin ebreak_vs_req_val = 0; end
        //if((trigger_no_match_val == 1) && (cebreak_val == 1) && (debug_req_i_val == 1)) begin cebreak_vs_req_val = 1; end else begin cebreak_vs_req_val = 0; end
        //if((ebreak_val == 1) && (step_no_dbg_val == 1)) begin ebreak_vs_step_val = 1; end else begin ebreak_vs_step_val = 0; end
        //if((cebreak_val == 1) && (step_no_dbg_val == 1)) begin cebreak_cs_step_val = 1; end else begin cebreak_cs_step_val = 0; end
        //if((debug_req_i_val == 1) && (step_no_dbg_val == 1)) begin dbg_req_vs_step_val = 1; end else begin dbg_req_vs_step_val = 0; end
        //prev_debug_req_i_val = debug_req_i_val;
        //prev_irq_i_val = irq_i_val;

        //`uvm_info("DEBUG_COVG",$psprintf("-------------------------------------------------------------------------------"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_cebreak_execute_with_ebreakm  #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex                              : %d", cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreakm_set                     : %d", ebreakm_set_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_with_ebreakm            : %d", cebreak_with_ebreakm_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_in_debug                : %d", cebreak_in_debug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_cebreak_execute_without_ebreakm  #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex                              : %d", cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreakm_clear                   : %d", ebreakm_clear_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("step                            : %d", step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("no_step                         : %d", no_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_regular_nodebug         : %d", cebreak_regular_nodebug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_step_nodebug            : %d", cebreak_step_nodebug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_counters_enabled                 #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mcycle_en                       : %d", mcycle_en_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("minstret_en                     : %d", minstret_en_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_at_reset                   #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("state                           : %d", state_reset_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dbg                             : %d", debug_req_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dbg_at_reset                    : %d", dbg_at_reset_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_causes                     #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("tmatch                          : %d", trigger_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("tnomatch                        : %d", trigger_no_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak                          : %d", ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak                         : %d", cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dbg_req                         : %d", debug_req_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("step                            : %d", step_no_dbg_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trig_vs_ebreak                  : %d", trig_vs_ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trig_vs_cebreak                 : %d", trig_vs_cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trig_vs_dbg_req                 : %d", trig_vs_dbg_req_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trig_vs_step                    : %d", trig_vs_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_vs_req                   : %d", ebreak_vs_req_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_vs_req                  : %d", cebreak_vs_req_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_vs_step                  : %d", ebreak_vs_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak_cs_step                 : %d", cebreak_cs_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dbg_req_vs_step                 : %d", dbg_req_vs_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_mode_ecall                 #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ill                             : %d", ecall_insn_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex_in_debug                     : %d", ex_in_debug_ecall_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_mode_exception             #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ill                             : %d", illegal_insn_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex_in_debug                     : %d", ex_in_debug_illegal_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_regs_d_mode                #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mode                            : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("access                          : %d", csr_access_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_read                         : %d", op_read_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_write                        : %d", op_write_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dcsr                       : %d", addr_dcsr_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dpc                        : %d", addr_dpc_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dscratch0                  : %d", addr_dscratch0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dscratch1                  : %d", addr_dscratch1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscr                 : %d", d_dres_access0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dpc                  : %d", d_dres_access1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscratch0            : %d", d_dres_access2_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscratch1            : %d", d_dres_access3_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscr                : %d", d_dres_access4_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dpc                 : %d", d_dres_access5_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscratch0           : %d", d_dres_access6_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscratch1           : %d", d_dres_access7_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_debug_regs_m_mode                #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mode                            : %d", machine_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("access                          : %d", csr_access_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_read                         : %d", op_read_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_write                        : %d", op_write_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dcsr                       : %d", addr_dcsr_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dpc                        : %d", addr_dpc_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dscratch0                  : %d", addr_dscratch0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_dscratch1                  : %d", addr_dscratch1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscr                 : %d", m_dres_access0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dpc                  : %d", m_dres_access1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscratch0            : %d", m_dres_access2_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,read,dscratch1            : %d", m_dres_access3_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscr                : %d", m_dres_access4_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dpc                 : %d", m_dres_access5_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscratch0           : %d", m_dres_access6_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("M,hit,write,dscratch1           : %d", m_dres_access7_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_ebreak_execute_with_ebreakm      #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex                              : %d", ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreakm_set                     : %d", ebreakm_set_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_with_ebreakm             : %d", ebreak_with_ebreakm_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_in_debug                 : %d", ebreak_in_debug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_ebreak_execute_without_ebreakm   #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex                              : %d", ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreakm_clear                   : %d", ebreakm_clear_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("step                            : %d", step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("no_step                         : %d", no_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_regular_nodebug          : %d", ebreak_regular_nodebug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak_step_nodebug             : %d", ebreak_step_nodebug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_fence_in_debug                   #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mode                            : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("fence                           : %d", fence_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("fence_in_debug                  : %d", fence_in_debug_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_irq_dreq                         #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dreq                            : %d", debug_req_i_trans_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq                             : %d", irq_i_trans_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trigger                         : %d", trigger_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ill                             : %d", illegal_insn_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ebreak                          : %d", ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("cebreak                         : %d", cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("branch                          : %d", branch_in_decode_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mulhsu                          : %d", is_mulhsu_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dreq_and_ill                    : %d", dreq_and_ill_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_and_dreq                    : %d", irq_and_dreq_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_dreq_trig_ill               : %d", irq_dreq_trig_ill_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_dreq_trig_cebreak           : %d", irq_dreq_trig_cebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_dreq_trig_ebreak            : %d", irq_dreq_trig_ebreak_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_dreq_trig_branch            : %d", irq_dreq_trig_branch_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq_dreq_trig_multicycle        : %d", irq_dreq_trig_multicycle_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_irq_in_debug                     #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("irq                             : %d", irq_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ex_in_debug                     : %d", ex_in_debug_irq_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_mmode_dret                       #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode                           : %d", machine_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dret_ins                        : %d", is_dret_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode                           : %d", dret_ex_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_single_step                      #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("step                            : %d", step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode                           : %d", machine_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("trigger                         : %d", trigger_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("iswfi                           : %d", is_wfi_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ill                             : %d", illegal_insn_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("pc_will_trig                    : %d", dpc_will_hit_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("stepie                          : %d", stepie_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step                      : %d", mmode_step_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step_trigger_match        : %d", mmode_step_trigger_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step_wfi                  : %d", mmode_step_wfi_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step_stepie               : %d", mmode_step_stepie_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step_illegal              : %d", mmode_step_illegal_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode_step_next_pc_will_match   : %d", mmode_step_next_pc_will_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_trigger_match                    #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("en                              : %d", trigger_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("match                           : %d", trigger_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("ok_match                        : %d", ok_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_trigger_match_disabled           #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dis                             : %d", trigger_dis_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("en                              : %d", trigger_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("match                           : %d", addr_match_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("mmode                           : %d", machine_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dmode                           : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("m_match_without_en              : %d", m_match_without_en_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("d_match_without_en              : %d", d_match_without_en_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("d_match_with_en                 : %d", d_match_with_en_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_trigger_regs                     #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0]                         : %d", machine_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1]                         : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("access                          : %d", csr_access_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_read                         : %d", op_read_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("op_write                        : %d", op_write_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_tsel                       : %d", addr_trigger_regs0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_tdata1                     : %d", addr_trigger_regs1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_tdata2                     : %d", addr_trigger_regs2_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_tdata3                     : %d", addr_trigger_regs3_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("addr_tinfo                      : %d", addr_trigger_regs4_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0],hit,read,tsel           : %d", tregs_access0_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0],hit,read,tdata1         : %d", tregs_access1_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0],hit,read,tdata2         : %d", tregs_access2_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0],hit,read,tdata3         : %d", tregs_access3_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[0],hit,read,tinfo          : %d", tregs_access4_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1],hit,read,tsel           : %d", tregs_access5_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1],hit,read,tdata1         : %d", tregs_access6_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1],hit,read,tdata2         : %d", tregs_access7_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1],hit,read,tdata3         : %d", tregs_access8_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("auto[1],hit,read,tinfo          : %d", tregs_access9_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_wfi_debug_req                    #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("inwfi                           : %d", in_wfi_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dreq                            : %d", debug_req_i_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm_wfi                          : %d", dm_wfi_req_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("#######  cg_wfi_in_debug                     #######"), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("iswfi                           : %d", is_wfi_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm                              : %d", debug_mode_q_val), UVM_LOW)
        //`uvm_info("DEBUG_COVG",$psprintf("dm_wfi                          : %d", dm_wfi_debug_val), UVM_LOW)
        //`uvm_info("DEBUGCOVG", "HERE I AM 2", UVM_LOW);
    //end

    cg_ebreak_execute_with_ebreakm.sample();
    cg_cebreak_execute_with_ebreakm.sample();
    cg_ebreak_execute_without_ebreakm.sample();
    cg_cebreak_execute_without_ebreakm.sample();
    cg_trigger_match.sample();
    cg_trigger_match_disabled.sample();
    cg_debug_mode_exception.sample();
    cg_debug_mode_ecall.sample();
    cg_irq_in_debug.sample();
    cg_wfi_in_debug.sample();
    cg_wfi_debug_req.sample();
    cg_single_step.sample();
    cg_mmode_dret.sample();
    cg_irq_dreq.sample();
    cg_debug_regs_d_mode.sample();
    cg_debug_regs_m_mode.sample();
    cg_trigger_regs.sample();
    cg_counters_enabled.sample();
    cg_debug_at_reset.sample();
    cg_fence_in_debug.sample();
    cg_debug_causes.sample();
  end
endtask  : sample_clk_i
