# This script should be run from the folder containing the result folders 
# generated after running from the checkpoints.

# NOTE: This script is for reference only. To be used once the SPEC CPU2017 
# results have been obtained by running the run_spec_benchmarks.sh script

find_val() {
	for file in ./*/stats.txt; do
		line=$(grep -rnw -h "$1" "$file" | sed -n "2p" | sed 's/^[^:]*://');
		value=$(grep -o "[0-9]\+" <<< $line)
		folder=$(dirname $file);
		echo "$1: $folder: $value"
	done
}

sort_val() {
custom_order="./base ./c3 ./c3-predtlb ./c3-forceDelay ./c3-predtlb-forceDelay"
value=$($1 $2);
echo "$value" | awk -v custom_order="$custom_order" '
    BEGIN {
        split(custom_order, order)
        for (i in order) {
	    rank[order[i]] = i
        }
    }
    {
        match($0, /\.\/[^:]+/)
        directory = substr($0, RSTART, RLENGTH)
        print rank[directory] " " $0
    }
' | sort -n
}


sort_val find_val "switch_cpus.numCycles"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.rdAccesses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.wrAccesses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.cryptoRdAccesses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.cryptoWrAccesses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.rdMisses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.wrMisses"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.linearReadPredTLBCorrect"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.linearWritePredTLBCorrect"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.cryptoReadPredTLBCorrect"
echo "**************************************"
sort_val find_val "switch_cpus.mmu.dtb.cryptoWritePredTLBCorrect"
echo "**************************************"
