
set script_dir [file dirname [info script]]

cd $script_dir

catch {exec g++ -o golden_model.exe golden_model.cpp}
catch {exec golden_model.exe}

puts "Golden Model C++ Executed Successfully! updated expected_regs.hex in $script_dir"
