flows=$(find pipeline/flows -name "flow.py" -exec dirname {} \; | xargs -n 1 basename | sort)
for flow in $flows; do
    echo "$flow"
done
