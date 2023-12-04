// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

struct XTransfer {
    uint32 srcChainId;
    uint32 dstChainId;
    bytes data;
}

enum XTransferStatus {
    Unknown,
    Initiated,
    Completed,
    Aborted
}
