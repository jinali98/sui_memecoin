module sui_memecoin::stitch_str_2;

use sui::coin::{Self, TreasuryCap};
use sui::url::new_unsafe_from_bytes;

const TOTAL_SUPPLY: u64 = 100_000_000_000;
const INITIAL_SUPPLY: u64 = 10_000_000_000;

// ---Error codes---
const EInvalidAmount: u64 = 0;
const EInsufficientSupply: u64 = 1;

public struct STITCH_STR_2 has drop {}

public struct MintCap has key, store {
    id: UID,
    minted_amount: u64,
}

fun init(otw: STITCH_STR_2, ctx: &mut TxContext) {
    let (mut treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"STITCH_STR_2",
        b"STITCH_STR_2",
        b"Stitch is a playful memecoin on Sui inspired by everyone's favorite duo, Lilo & Stitch. Fueled by the spirit of ohana, STITCH lets fans tip, swap and celebrate with little experiments of value—bringing that Hawaiian heart and mischief right onto the blockchain",
        option::some(
            new_unsafe_from_bytes(
                b"https://static.wikia.nocookie.net/the-stitch/images/e/e9/Stitch_OfficialDisney.jpg/revision/latest?cb=20140911233238",
            ),
        ),
        ctx,
    );

    let mut mint_cap = MintCap {
        id: object::new(ctx),
        minted_amount: 0,
    };

    mint(&mut treasury, &mut mint_cap, INITIAL_SUPPLY, ctx.sender(), ctx);

    transfer::public_freeze_object(metadata);

    // transfer the mint cap to the creator
    transfer::public_transfer(mint_cap, ctx.sender());

    // transfer the treasury to the creator for future use
    transfer::public_transfer(treasury, ctx.sender());
}

// mint function is used to mint coins to a recipient
public fun mint(
    treasury: &mut TreasuryCap<STITCH_STR_2>,
    mint_cap: &mut MintCap,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    assert!(amount > 0, EInvalidAmount);
    assert!(mint_cap.minted_amount + amount <= TOTAL_SUPPLY, EInsufficientSupply);

    let minted_amount = mint_cap.minted_amount + amount;
    mint_cap.minted_amount = minted_amount;

    let coin = coin::mint(treasury, amount, ctx);
    transfer::public_transfer(coin, recipient);
}
