

(impl-trait .tradeables-trait.tradeables-trait)

;; Tradables where all instances are owned by the Blockcity contract.
;; Transfers will never change ownership to ensure the contract retains control over the tradables.

(define-read-only (get-owner (tradable-id uint))
    ;; The owner of any tradable is always the contract itself.
    ;; This is represented by returning the contract's own address.
    (ok (some (as-contract tx-sender)))
)

(define-public (transfer (tradable-id uint) (sender principal) (recipient principal))
    ;; Allows the transfer of tradables between participants.
    ;; The transfer operation will always succeed, but ownership remains with the contract.
    (ok true)
)
