module sui_memecoin::stitch_str_3;

use bridge::treasury;
use sui::balance::{Self, Balance};
use sui::clock::{Self, Clock};
use sui::coin::{Self, TreasuryCap};
use sui::url::new_unsafe_from_bytes;

const TOTAL_SUPPLY: u64 = 100_000_000_000;
const INITIAL_SUPPLY: u64 = 10_000_000_000;

// ---Error codes---
const EInvalidAmount: u64 = 0;
const EInsufficientSupply: u64 = 1;
const EInvalidTime: u64 = 2;

public struct STITCH_STR_3 has drop {}

public struct MintCap has key, store {
    id: UID,
    treasury_cap: TreasuryCap<STITCH_STR_3>,
    minted_amount: u64,
}

public struct CoinLocker has key, store {
    id: UID,
    balance: Balance<STITCH_STR_3>,
    // in milliseconds
    unlock_time: u64,
}

fun init(otw: STITCH_STR_3, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        otw,
        9,
        b"STITCH_STR_3",
        b"STITCH_STR_3",
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
        treasury_cap: treasury,
        minted_amount: 0,
    };

    token_minting_handler(&mut mint_cap, INITIAL_SUPPLY, ctx.sender(), ctx);

    transfer::public_freeze_object(metadata);

    // transfer the mint cap to the creator
    transfer::public_transfer(mint_cap, ctx.sender());
}

// mint function is used to mint coins to a recipient
public fun token_minting_handler(
    mint_cap: &mut MintCap,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = mint_tokens(mint_cap, amount, ctx);
    transfer::public_transfer(coin, recipient);
}

public fun release_locked_tokens(
    locker: &mut CoinLocker,
    recipient: address,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    assert!(locker.unlock_time <= clock.timestamp_ms(), EInvalidTime);
    let locked_balance = locker.balance.value();

    let unlocked_amount = coin::take(&mut locker.balance, locked_balance, ctx);
    transfer::public_transfer(unlocked_amount, recipient)
}

fun mint_tokens(
    mint_cap: &mut MintCap,
    amount: u64,
    ctx: &mut TxContext,
): coin::Coin<STITCH_STR_3> {
    assert!(amount > 0, EInvalidAmount);
    assert!(mint_cap.minted_amount + amount <= TOTAL_SUPPLY, EInsufficientSupply);

    let treasury = &mut mint_cap.treasury_cap;

    let coin = coin::mint(treasury, amount, ctx);
    mint_cap.minted_amount = mint_cap.minted_amount + amount;
    coin
}

fun mint_and_lock(
    mint_cap: &mut MintCap,
    amount: u64,
    duration: u64, // in milliseconds
    recipient: address,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let coin = mint_tokens(mint_cap, amount, ctx);
    let current_date = clock.timestamp_ms();
    let unlock_date = current_date + duration;

    let locker = CoinLocker {
        id: object::new(ctx),
        balance: coin::into_balance(coin),
        unlock_time: unlock_date,
    };

    transfer::public_transfer(locker, recipient);
}

#[test_only]
use sui::test_scenario::{Self, Scenario};
#[test]
fun test_init() {
    let publisher = @0xA1;

    let mut scenario = test_scenario::begin(publisher);
    {
        let otw = STITCH_STR_3 {};

        init(otw, scenario.ctx());
    };
    scenario.next_tx(publisher);
    {
        let mint_cap = scenario.take_from_sender<MintCap>();
        let stitch_coins = scenario.take_from_sender<coin::Coin<STITCH_STR_3>>();

        assert!(mint_cap.minted_amount == INITIAL_SUPPLY, EInvalidAmount);
        assert!(stitch_coins.balance().value() == INITIAL_SUPPLY, EInvalidAmount);

        scenario.return_to_sender(mint_cap);
        scenario.return_to_sender(stitch_coins);
    };
    scenario.next_tx(publisher);
    {
        let mut mint_cap = scenario.take_from_sender<MintCap>();

        token_minting_handler(&mut mint_cap, 1000000000, publisher, scenario.ctx());

        assert!(mint_cap.minted_amount == INITIAL_SUPPLY + 1000000000, EInvalidAmount);

        scenario.return_to_sender(mint_cap);
    };
    scenario.next_tx(publisher);
    {
       
    };
    scenario.end();
}
