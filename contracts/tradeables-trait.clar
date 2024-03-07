(define-trait tradables-trait
    (
        ;; Retrieves the owner of a given asset, uniquely identified.
        (get-owner ( uint) (response (optional principal) uint))

        ;; Transfers an asset from the sender to a new principal, accommodating unique asset transfers.
        (transfer ( uint principal principal) (response bool uint))
    )
)
