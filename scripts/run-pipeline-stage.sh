flows=$(find pipeline/flows -name "flow.py" -exec dirname {} \; | xargs -n 1 basename | sort)

requested_flow=$1
if [[ -z "$requested_flow" ]]; then
    echo "Usage: $0 <stage>"
    exit 1
fi

poetry run python3 -m pipeline.flows."$requested_flow".flow run
