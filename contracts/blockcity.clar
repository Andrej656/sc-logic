(define-trait tradeables-trait)

;; Market Listings Map
(define-map on-sale
  {owner: principal, tradables: principal, tradable-id: uint}
  {price: uint, duration: uint, asset-type: (string-ascii 10)}
)

;; Offers Map
(define-map offers 
  {bid-owner: principal, owner: principal, tradables: principal, tradable-id: uint}
  {price: uint, asset-type: (string-ascii 10)}
)

;; Accepting Owners Map
(define-map accepting-owners 
  {tradables: principal, tradable-id: uint}
  {owner: principal, asset-type: (string-ascii 10)}
)

;; Error Constants
(define-constant err-invalid-offer-key u1)
(define-constant err-payment-failed u2)
(define-constant err-transfer-failed u3)
(define-constant err-not-allowed u4)
(define-constant err-duplicate-entry u5)
(define-constant err-tradable-not-found u6)

;; Private Functions for Asset Management
(define-private (get-owner (tradables <tradeables-trait>) (tradable-id uint))
  (contract-call? tradables get-owner tradable-id)
)

;; Adjusted for Asset Type Handling
(define-private (transfer-tradable-to-escrow (tradables <tradeables-trait>) (tradable-id uint) (asset-type (string-ascii 10)))
  (begin
    (map-insert accepting-owners {tradables: (contract-of tradables), tradable-id: tradable-id} {owner: tx-sender, asset-type: asset-type})
    (contract-call? tradables transfer tradable-id tx-sender (as-contract tx-sender))
  )
)

(define-private (transfer-tradable-from-escrow (tradables <tradeables-trait>) (tradable-id uint) (asset-type (string-ascii 10)))
  (let ((owner tx-sender))
    (begin
      (map-delete accepting-owners {tradables: (contract-of tradables), tradable-id: tradable-id})
      (as-contract (contract-call? tradables transfer tradable-id (as-contract tx-sender) owner))
    )
  )
)

;; Public Functions for Marketplace Operations, Adjusted for SIP-009 and STX-20
;; These functions now include an 'asset-type' parameter to differentiate between SIP-009 NFTs and STX-20 digital artifacts.
;; Implement logic within these functions to handle the two asset types appropriately, 
;; especially in terms of transfer logic, payment processing, and listing management.

;; The implementation details within each function will vary based on how STX-20 assets are specifically managed,
;; including their transfer mechanics and how they integrate with the Stacks blockchain's features.

