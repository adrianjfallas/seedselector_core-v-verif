`uvm_info("BASE TEST", $sformatf("SEED_SELECTOR: including seed_selector.sv"), UVM_LOW)
seed_selector_result = build_base_covmodel_tree(current_test_name_id);

if (seed_selector_result == 7) begin
   `uvm_fatal(get_type_name(), "SEED_SELECTOR: DISCARDED")
end
