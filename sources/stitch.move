module sui_memecoin::stitch;

use sui::coin::{Self, TreasuryCap};
use sui::transfer;
use sui::url::new_unsafe_from_bytes;

public struct STITCH has drop {}

// we want to mint only 100 STITCH coins
// as we have 9 decimals set, we need to multiply by 10^9 to get the total supply in base units
// 1 STITCH = 1,000,000,000 base units
// We provide the total supply in base units, in that case, we need to multiply by 10^9 to get the total supply in the base units
const TOTAL_SUPPLY: u64 = 100_000_000_000;


fun init(otw: STITCH, ctx: &mut TxContext) {
   let (mut treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"STITCH",
        b"STITCH",
        b"Stitch is a playful memecoin on Sui inspired by everyone's favorite duo, Lilo & Stitch. Fueled by the spirit of ohana, STITCH lets fans tip, swap and celebrate with little experiments of value—bringing that Hawaiian heart and mischief right onto the blockchain",
        option::some(new_unsafe_from_bytes(b"https://static.wikia.nocookie.net/the-stitch/images/e/e9/Stitch_OfficialDisney.jpg/revision/latest?cb=20140911233238")),
        ctx,
    );    

    // mint the total supply to the treasury during initialization
    mint(&mut treasury, TOTAL_SUPPLY, ctx.sender(), ctx);

    // Freeze the meta data so its immutable
    transfer::public_freeze_object(metadata);

    // freeze the treasury so its immutable
    transfer::public_freeze_object(treasury);

    // transfer::public_transfer(treasury, ctx.sender());
}


// OPTION 1: Mint the total supply to the treasury during initialization and freeze the treasury so its not possible to mint more coins
// OPTION 2 : distribute a fixed amount of coins to a recipient during initialization (community, operations..etc)

// mint function is used to mint STITCH coins to a recipient
public fun mint(treasury: &mut TreasuryCap<STITCH>, amount: u64, recipient: address, ctx: &mut TxContext) {
   let coin = coin::mint(treasury, amount, ctx);
   transfer::public_transfer(coin, recipient);
}


