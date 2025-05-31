module sui_memecoin::stitch_str_1;

use sui::coin::{Self, TreasuryCap};
use sui::transfer;
use sui::url::new_unsafe_from_bytes;

public struct STITCH_STR_1 has drop {}

// we want to mint only 100 STITCH coins
// as we have 9 decimals set, we need to multiply by 10^9 to get the total supply in base units
// 1 STITCH = 1,000,000,000 base units
// We provide the total supply in base units, in that case, we need to multiply by 10^9 to get the total supply in the base units
const COMMUNITY_SUPPLY: u64 = 50_000_000_000;
const OPERATIONS_SUPPLY: u64 = 25_000_000_000;
const CEX_LISTINGS_SUPPLY: u64 = 25_000_000_000;

fun init(otw: STITCH_STR_1, ctx: &mut TxContext) {
    let (mut treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"STITCH_STR_1",
        b"STITCH_STR_1",
        b"Stitch is a playful memecoin on Sui inspired by everyone's favorite duo, Lilo & Stitch. Fueled by the spirit of ohana, STITCH lets fans tip, swap and celebrate with little experiments of value—bringing that Hawaiian heart and mischief right onto the blockchain",
        option::some(
            new_unsafe_from_bytes(
                b"https://static.wikia.nocookie.net/the-stitch/images/e/e9/Stitch_OfficialDisney.jpg/revision/latest?cb=20140911233238",
            ),
        ),
        ctx,
    );

    // mint the total supply various recipients during initialization
    mint(&mut treasury, COMMUNITY_SUPPLY, @stitch_community, ctx);
    mint(&mut treasury, OPERATIONS_SUPPLY, @stitch_operations, ctx);
    mint(&mut treasury, CEX_LISTINGS_SUPPLY, @stitch_cex_listings, ctx);

    transfer::public_freeze_object(metadata);
    transfer::public_freeze_object(treasury);

}

// mint function is used to mint STITCH coins to a recipient
public fun mint(
    treasury: &mut TreasuryCap<STITCH_STR_1>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury, amount, ctx);
    transfer::public_transfer(coin, recipient);
}
