# STITCH Memecoin on Sui

This repository contains a simple Sui Move module that defines a capped‐supply memecoin called **STITCH**. Inspired by Lilo & Stitch, this token mints exactly 100 STITCH (with 9 decimal places) and immediately freezes both its metadata and mint cap to lock in that supply.

---

## What It Does

* **Module**: `sui_memecoin::stitch`

  * Declares an empty `STITCH` struct as the coin’s unique type.
  * Uses `coin::create_currency` to create `TreasuryCap<STITCH>` and `CoinMetadata<STITCH>` with:

    * **Decimals**: 9
    * **Symbol**: `STITCH`
    * **Name**: `STITCH`
    * **Description**: “Stitch is a playful memecoin on Sui inspired by everyone’s favorite duo, Lilo & Stitch. Fueled by the spirit of ohana, STITCH lets fans tip, swap, and celebrate with little experiments of value—bringing that Hawaiian heart and mischief right onto the blockchain.”
    * **Icon URL**: A link to a Stitch image on Wikipedia.

* **Total Supply**: `100` STITCH tokens

  * Because of 9 decimals, that equals `100 × 10⁹ = 100,000,000,000` base units.

* **Initialization (`init`)**:

  1. Accepts a one‐time witness (`otw: STITCH`) and transaction context.
  2. Calls `coin::create_currency(…)` to set up the mint cap and metadata.
  3. Mints the full 100 STITCH directly into the deployer’s wallet.
  4. Freezes the `CoinMetadata<STITCH>` so name, symbol, decimals, description, and icon URL can never be changed.
  5. Freezes the `TreasuryCap<STITCH>` to prevent any further minting.

* **Mint Function (`mint`)**:

  * Allows minting additional STITCH tokens (only if the treasury cap is not yet frozen).
  * In this example, the treasury is frozen immediately, so no further minting is possible after deployment.

---

## Next Steps

Before publishing to Sui, make sure the module builds without errors:

```bash
sui move build
```

Once there are no build errors, publish the package. This action will mint 100 STITCH tokens to your wallet address:

```bash
sui client publish
```

The CLI will return a success response along with detailed object changes, confirming that 100 STITCH tokens have been minted to your address.
