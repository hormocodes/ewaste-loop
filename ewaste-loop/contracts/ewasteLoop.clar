;; ewaste-loop: E-Waste Circular Supply Chain Tracker
;; A smart contract for tracking electronic devices through their lifecycle

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-stage (err u103))
(define-constant err-already-exists (err u104))

;; Device lifecycle stages
(define-constant stage-collected u1)
(define-constant stage-dismantled u2)
(define-constant stage-material-recovered u3)
(define-constant stage-remanufactured u4)

;; Data Variables
(define-data-var device-counter uint u0)

;; Data Maps

;; Store device information
(define-map devices
    { device-id: uint }
    {
        device-type: (string-ascii 50),
        manufacturer: (string-ascii 50),
        serial-number: (string-ascii 100),
        current-stage: uint,
        current-holder: principal,
        created-at: uint
    }
)

;; Track device history through stages
(define-map device-history
    { device-id: uint, stage: uint }
    {
        holder: principal,
        location: (string-ascii 100),
        timestamp: uint,
        notes: (string-ascii 200)
    }
)

;; Store material recovery data
(define-map materials-recovered
    { device-id: uint }
    {
        copper-kg: uint,
        gold-g: uint,
        silver-g: uint,
        plastic-kg: uint,
        other-materials: (string-ascii 200),
        recovery-date: uint
    }
)

;; Track authorized participants in the supply chain
(define-map authorized-participants
    { participant: principal }
    {
        role: (string-ascii 30),
        authorized: bool
    }
)

;; Read-only functions

;; Get device information
(define-read-only (get-device (device-id uint))
    (map-get? devices { device-id: device-id })
)

;; Get device history for a specific stage
(define-read-only (get-device-stage-history (device-id uint) (stage uint))
    (map-get? device-history { device-id: device-id, stage: stage })
)

;; Get materials recovered from a device
(define-read-only (get-materials-recovered (device-id uint))
    (map-get? materials-recovered { device-id: device-id })
)

;; Check if participant is authorized
(define-read-only (is-authorized (participant principal))
    (default-to false 
        (get authorized 
            (map-get? authorized-participants { participant: participant })
        )
    )
)

;; Get current device counter
(define-read-only (get-device-counter)
    (ok (var-get device-counter))
)

;; Public functions

;; Authorize a participant (only contract owner)
(define-public (authorize-participant (participant principal) (role (string-ascii 30)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-participants
            { participant: participant }
            { role: role, authorized: true }
        ))
    )
)

;; Revoke participant authorization (only contract owner)
(define-public (revoke-authorization (participant principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-participants
            { participant: participant }
            { role: "", authorized: false }
        ))
    )
)

;; Register a new e-waste device (collection stage)
(define-public (register-device 
    (device-type (string-ascii 50))
    (manufacturer (string-ascii 50))
    (serial-number (string-ascii 100))
    (location (string-ascii 100))
    (notes (string-ascii 200))
)
    (let
        (
            (new-device-id (+ (var-get device-counter) u1))
        )
        (asserts! (is-authorized tx-sender) err-unauthorized)
        
        ;; Create device record
        (map-set devices
            { device-id: new-device-id }
            {
                device-type: device-type,
                manufacturer: manufacturer,
                serial-number: serial-number,
                current-stage: stage-collected,
                current-holder: tx-sender,
                created-at: stacks-block-height
            }
        )
        
        ;; Record collection history
        (map-set device-history
            { device-id: new-device-id, stage: stage-collected }
            {
                holder: tx-sender,
                location: location,
                timestamp: stacks-block-height,
                notes: notes
            }
        )
        
        ;; Increment counter
        (var-set device-counter new-device-id)
        (ok new-device-id)
    )
)

;; Update device to dismantling stage
(define-public (dismantle-device
    (device-id uint)
    (location (string-ascii 100))
    (notes (string-ascii 200))
)
    (let
        (
            (device (unwrap! (map-get? devices { device-id: device-id }) err-not-found))
        )
        (asserts! (is-authorized tx-sender) err-unauthorized)
        (asserts! (is-eq (get current-stage device) stage-collected) err-invalid-stage)
        
        ;; Update device stage
        (map-set devices
            { device-id: device-id }
            (merge device { 
                current-stage: stage-dismantled,
                current-holder: tx-sender
            })
        )
        
        ;; Record dismantling history
        (map-set device-history
            { device-id: device-id, stage: stage-dismantled }
            {
                holder: tx-sender,
                location: location,
                timestamp: stacks-block-height,
                notes: notes
            }
        )
        
        (ok true)
    )
)

;; Record material recovery
(define-public (recover-materials
    (device-id uint)
    (copper-kg uint)
    (gold-g uint)
    (silver-g uint)
    (plastic-kg uint)
    (other-materials (string-ascii 200))
    (location (string-ascii 100))
    (notes (string-ascii 200))
)
    (let
        (
            (device (unwrap! (map-get? devices { device-id: device-id }) err-not-found))
        )
        (asserts! (is-authorized tx-sender) err-unauthorized)
        (asserts! (is-eq (get current-stage device) stage-dismantled) err-invalid-stage)
        
        ;; Update device stage
        (map-set devices
            { device-id: device-id }
            (merge device { 
                current-stage: stage-material-recovered,
                current-holder: tx-sender
            })
        )
        
        ;; Record materials recovered
        (map-set materials-recovered
            { device-id: device-id }
            {
                copper-kg: copper-kg,
                gold-g: gold-g,
                silver-g: silver-g,
                plastic-kg: plastic-kg,
                other-materials: other-materials,
                recovery-date: stacks-block-height
            }
        )
        
        ;; Record recovery history
        (map-set device-history
            { device-id: device-id, stage: stage-material-recovered }
            {
                holder: tx-sender,
                location: location,
                timestamp: stacks-block-height,
                notes: notes
            }
        )
        
        (ok true)
    )
)

;; Record remanufacturing
(define-public (remanufacture-device
    (device-id uint)
    (location (string-ascii 100))
    (notes (string-ascii 200))
)
    (let
        (
            (device (unwrap! (map-get? devices { device-id: device-id }) err-not-found))
        )
        (asserts! (is-authorized tx-sender) err-unauthorized)
        (asserts! (is-eq (get current-stage device) stage-material-recovered) err-invalid-stage)
        
        ;; Update device stage
        (map-set devices
            { device-id: device-id }
            (merge device { 
                current-stage: stage-remanufactured,
                current-holder: tx-sender
            })
        )
        
        ;; Record remanufacturing history
        (map-set device-history
            { device-id: device-id, stage: stage-remanufactured }
            {
                holder: tx-sender,
                location: location,
                timestamp: stacks-block-height,
                notes: notes
            }
        )
        
        (ok true)
    )
)

;; Transfer device to another authorized participant
(define-public (transfer-device
    (device-id uint)
    (new-holder principal)
)
    (let
        (
            (device (unwrap! (map-get? devices { device-id: device-id }) err-not-found))
        )
        (asserts! (is-authorized tx-sender) err-unauthorized)
        (asserts! (is-authorized new-holder) err-unauthorized)
        (asserts! (is-eq (get current-holder device) tx-sender) err-unauthorized)
        
        ;; Update device holder
        (map-set devices
            { device-id: device-id }
            (merge device { current-holder: new-holder })
        )
        
        (ok true)
    )
)