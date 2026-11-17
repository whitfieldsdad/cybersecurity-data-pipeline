flow=$1
if [[ -z "$flow" ]]; then
    echo "Usage: $0 <stage>"
    exit 1
fi

flow=${flow//-/_}
poetry run python3 -m pipeline.flows."$flow".flow run
