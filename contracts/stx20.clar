;; Constants for operations
(define-constant MINT_OPERATION "m")
(define-constant TRANSFER_OPERATION "t")
(define-constant DEPLOY_OPERATION "d")

;; Map to track STX20 token metadata and ownership
(define-map stx20-tokens
  {ticker: (string-ascii 8)}
  {owner: principal, total-supply: uint, limit-per-mint: uint}
)

;; Map for marketplace listings
(define-map listings
  {ticker: (string-ascii 8), listed-by: principal}
  {price: uint}
)

;; Error codes
(define-constant ERR_TOKEN_EXISTS u1)
(define-constant ERR_TOKEN_NOT_FOUND u2)
(define-constant ERR_NOT_OWNER u3)
(define-constant ERR_LISTING_NOT_FOUND u4)
(define-constant ERR_NOT_ENOUGH_STX u5)

;; Register a minted STX20 token (post-mint)
(define-public (register-mint (ticker (string-ascii 8)) (total-supply uint) (limit-per-mint uint))
  (let ((existing-entry (map-get? stx20-tokens {ticker: ticker})))
    (if (is-none existing-entry)
      (begin
        (map-insert stx20-tokens {ticker: ticker} {owner: tx-sender, total-supply: total-supply, limit-per-mint: limit-per-mint})
        (ok true))
      (err ERR_TOKEN_EXISTS)
    )
  )
)

;; List an STX20 token for sale
(define-public (list-for-sale (ticker (string-ascii 8)) (price uint))
  (let ((token-entry (map-get? stx20-tokens {ticker: ticker})))
    (if (and (is-some token-entry) (is-eq tx-sender (get owner (unwrap! token-entry (err ERR_TOKEN_NOT_FOUND)))))
      (begin
        (map-insert listings {ticker: ticker, listed-by: tx-sender} {price: price})
        (ok true))
      (err ERR_NOT_OWNER)
    )
  )
)

;; Buy a listed STX20 token
(define-public (buy (ticker (string-ascii 8)))
  (let ((listing-entry (map-get? listings {ticker: ticker, listed-by: tx-sender})))
    (if (is-none listing-entry)
      (err ERR_LISTING_NOT_FOUND)
      (let ((price (get price (unwrap! listing-entry (err ERR_LISTING_NOT_FOUND)))))
        (if (>= (stx-get-balance tx-sender) price)
          (begin
            ;; Transfer STX to seller
            (stx-transfer? price tx-sender (get listed-by (unwrap! listing-entry (err ERR_LISTING_NOT_FOUND))))
            ;; Update token ownership (This step would need off-chain coordination with STX20 protocol)
            ;; Remove listing
            (map-delete listings {ticker: ticker, listed-by: tx-sender})
            (ok true))
          (err ERR_NOT_ENOUGH_STX)
        )
      )
    )
  )
)

;; Unlist an STX20 token
(define-public (unlist (ticker (string-ascii 8)))
  (let ((listing-entry (map-get? listings {ticker: ticker, listed-by: tx-sender})))
    (if (is-none listing-entry)
      (err ERR_LISTING_NOT_FOUND)
      (begin
        (map-delete listings {ticker: ticker, listed-by: tx-sender})
        (ok true)
      )
    )
  )
)

;; Additional logic for transfer registration and handling specific to STX20 protocol would be required
