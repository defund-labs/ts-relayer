#!/bin/bash

# exit script on any error
set -e

compare_replace_config() {
	TARGET_FILE=$1
	TEMP_FILE=$2

	if [ ! -f "$TARGET_FILE" ]; then
		echo "no existing file found, creating.."
		mv "$TEMP_FILE" "$TARGET_FILE"
	else
		TARGET_FILE_HASH=$(sha256sum "$TARGET_FILE" | awk '{print $1}')
		TEMP_FILE_HASH=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
		if [ "$TARGET_FILE_HASH" = "$TEMP_FILE_HASH" ]; then
			echo "$TARGET_FILE is up-to-date -- $TARGET_FILE_HASH"
			rm "$TEMP_FILE"
		else
			echo "changes detected, updating.."
			rm "$TARGET_FILE"
			mv "$TEMP_FILE" "$TARGET_FILE"
		fi
	fi

}

write_app_yaml() {
	cat >app.yaml <<EOF
src: $SRC_CHAINID
dest: $DEST_CHAINID
mnemonic: $MNEMONIC
EOF
}

write_registry_yaml() {
	cat >registry.yaml <<EOF
version: 1

chains:
  $SRC_CHAINID:
    chain_id: $SRC_CHAINID
    prefix: $SRC_CHAIN_PREFIX
    gas_price: $SRC_CHAIN_GAS
    hd_path: m/44'/118'/0'/0/0
    ics20_port: 'transfer'
    estimated_block_time: $SRC_BLOCK_TIME
    estimated_indexer_time: 250
    rpc:
      - $SRC_CHAIN_RPC
  $DEST_CHAINID:
    chain_id: $DEST_CHAINID
    prefix: $DEST_CHAIN_PREFIX
    gas_price: $DEST_CHAIN_GAS
    hd_path: m/44'/118'/0'/0/0
    ics20_port: 'transfer'
    estimated_block_time: $DEST_BLOCK_TIME
    estimated_indexer_time: 250
    rpc:
      - $DEST_CHAIN_RPC
EOF
}

update_config_files() {
	CONFIG_DIR=$1
	TEMP_DIR="${CONFIG_DIR}/temp"

	mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

	write_app_yaml
	write_registry_yaml

	cd "$CONFIG_DIR"

	compare_replace_config "${CONFIG_DIR}/app.yaml" "${TEMP_DIR}/app.yaml"
	compare_replace_config "${CONFIG_DIR}/registry.yaml" "${TEMP_DIR}/registry.yaml"

	rm -rf "$TEMP_DIR"
}

update_config_files "/root/.ibc-setup"

ibc-relayer start --src-connection $SRC_CONNECTION --dest-connection $DEST_CONNECTION --poll $POLL_SEC --log-level $LOG_LEVEL