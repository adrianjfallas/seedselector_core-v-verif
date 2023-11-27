class TreeNode;
   //properties
   int node_id;
   string name;
   TreeNode children [$];
   TreeNode parent;
   int level;
   real functional_cov_overall_covered;
   int functional_cov_points_covered;
   int functional_cov_points_total;
   int weight;
   string influence_param;
   int influence_param_range_min;
   int influence_param_range_max;
   int influence_param_list_of_values [];

   //constructor method
   function new();
      node_id = 1;
      name = "root";
      level = 0;
      functional_cov_overall_covered = 0.0;
      functional_cov_points_covered = 0;
      functional_cov_points_total = 0;
      weight = 1;
      influence_param = "";
      influence_param_range_min = 0;
      influence_param_range_max = 0;
   endfunction

   function void print_tree(int details = 0);
      string spaces = {this.level{"   "}};
      string prefix, prefix2, s = "";
      if (this.node_id != 1 ) begin
        prefix = {spaces, "|__"};
        prefix2 = {spaces, "***"};
      end
      $display({prefix, this.name});
      if ((this.node_id != 1) && (details == 1)) begin
         s.realtoa(this.functional_cov_overall_covered);
         $display({prefix2, "functional_cov_overall_covered: ", s, "%"});
         s.itoa(this.functional_cov_points_covered);
         $display({prefix2, "functional_cov_points_covered : ", s});
         s.itoa(this.functional_cov_points_total);
         $display({prefix2, "functional_cov_points_total   : ", s});
         s.itoa(this.weight);
         $display({prefix2, "weight                        : ", s});
         $display({prefix2, "influence_param               : ", this.influence_param});
         s.itoa(this.influence_param_range_min);
         $display({prefix2, "influence_param_range_min     : ", s});
         s.itoa(this.influence_param_range_max);
         $display({prefix2, "influence_param_range_max     : ", s});
         s = $sformatf("%p", this.influence_param_list_of_values);
         $display({prefix2, "influence_param_list_of_values: ", s});
      end
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              this.children[i].print_tree(details);
         end
      end
   endfunction

   function void add_child(TreeNode child);
       this.children.push_back(child);
   endfunction

   function void update_seed_tree_weight(int influence_param_val);
      if ((this.level == 3 ) && (((influence_param_val >= this.influence_param_range_min) && (influence_param_val <= this.influence_param_range_max)) || (influence_param_val inside {this.influence_param_list_of_values}))) begin
         this.weight = 0;
      end
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              this.children[i].update_seed_tree_weight(influence_param_val);
         end
      end
   endfunction

   function int get_tree_weight();
      int weight = 0;
      weight = weight + this.weight;
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              weight = weight + this.children[i].get_tree_weight();
         end
      end
      return weight;
   endfunction

   function void set_cov_data(real ovr_covered, int cov_points_covered, int cov_points_total);
       this.functional_cov_overall_covered = ovr_covered;
       this.functional_cov_points_covered = cov_points_covered;
       this.functional_cov_points_total = cov_points_total;
       this.weight = (cov_points_total>cov_points_covered) ? (cov_points_total-cov_points_covered) : 0;
   endfunction

   function void set_influence_param_data(string influence_parameter, int influence_parameter_range_min, int influence_parameter_range_max, int influence_parameter_list_of_values []);
       this.influence_param = influence_parameter;
       this.influence_param_range_min = influence_parameter_range_min;
       this.influence_param_range_max = influence_parameter_range_max;
       this.influence_param_list_of_values = influence_parameter_list_of_values;
   endfunction

   function void add_influence_param_data();
       if (this.level == 3) begin
          case (node_id)
             4,286   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{2});
                  end
             5,8   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{4});
                  end
             6,116,123   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 6, 7, 8});
                  end
             7,12   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{6, 7});
                  end
             9,202,207,224,248   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3, 6, 7, 8});
                  end
             10   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{5, 6, 7, 8});
                  end
             11,15   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{6, 7, 8});
                  end
             13,316,318   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{6, 8});
                  end
             14,16,324   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{7});
                  end
             19,21,25,30,32,36,41,54,172,174,300,302   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 3, 6, 8});
                  end
             23,34,43,47,56,60,74,78,80,82,84,91,98,105,112,114,119,121,128,132,134,136,138,155,156,158,161,170,176,195,197,199,200,203,204,208,217,219,221,222,225,226,239,240,242,244,245,276,279,282,284,289,298,304   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3, 4, 5, 6, 7, 8});
                  end
             27,38   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 8});
                  end
             45,58,126   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 7});
                  end
             49,51,62,64,95,102,139,143,148,152,229,230,231,232,233,234,235,236,253,256,257,258,259,260,261,262,291,293,314,320,322   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1});
                  end
             67,76,211,264,269,270   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3});
                  end
             69,71,88,107,109,130,166,168,182,254,255,275,278,296   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 3});
                  end
             86   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 4, 5});
                  end
             93,100,160   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 5});
                  end
             141,145,147,150,306   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 7});
                  end
             164,180   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 3, 4, 5, 6, 7, 8});
                  end
             178   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{3, 6, 7, 8});
                  end
             184,186,188,190,192,308,310,312   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{3});
                  end
             205,209,210,213,227   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3, 5, 6, 7, 8});
                  end
             212   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3, 6, 8});
                  end
             214   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 3, 5, 7, 8});
                  end
             247,250,251   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2, 6, 7, 8});
                  end
             249   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2,3, 6, 7});
                  end
             263,265,266,267,268,271,272   :  begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{1, 2});
                  end
             default : begin
                     this.set_influence_param_data("current_test_name", 0, 0, '{"none"});
                  end
          endcase
       end

   endfunction

endclass
