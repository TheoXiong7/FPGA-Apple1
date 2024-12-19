# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\theox\Desktop\aapl1_urbana\workspace\apple1_urbana_v1\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\theox\Desktop\aapl1_urbana\workspace\apple1_urbana_v1\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {apple1_urbana_v1}\
-hw {C:\Users\theox\Desktop\aapl1_urbana\apple1_urbana_v1.xsa}\
-out {C:/Users/theox/Desktop/aapl1_urbana/workspace}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {apple1_urbana_v1}
platform generate -quick
platform generate
