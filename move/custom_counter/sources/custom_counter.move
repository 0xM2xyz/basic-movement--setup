module custom_counter::custom_counter {
    use sui::object::{Self, UID};
    // use sui::transfer;
    use sui::tx_context::{TxContext, sender};
    // use std::string::String;
    // use std::vector;
    // use sui::event;


    // Define the Counter structure
    public struct Counter has store,key {
        id: UID,
        owner: address,
        value: u64,
    }

    public struct CounterStored has store, copy {
        id: address,
        owner: address,
        value: u64,
    }
    

    // Define the CountersCollection structure
    public struct CountersCollection has key {
        id: UID,
        counters: vector<CounterStored>,
    }

    // Initialization function to create the CountersCollection as a shared object
     fun init(ctx: &mut TxContext) {
        let collection = CountersCollection {
            id: object::new(ctx),
            counters: vector::empty<CounterStored>(),
        };
        transfer::share_object(collection);
    }


  /// Create and share a Counter object.
  public fun create(collectionCounters: &mut CountersCollection, ctx: &mut TxContext) {

    let  counter_id = object::new(ctx);
    let counter =  Counter {
      id:counter_id ,
      owner: ctx.sender(),
      value: 0};
    let address_of_counter = object::uid_to_address( &counter.id);
    let createdCounter = CounterStored {
      id: address_of_counter,
         owner: ctx.sender(),
        value: 0,
    };
    vector::push_back(  &mut collectionCounters.counters, createdCounter);
    transfer::share_object(
      counter
    );
  }

  /// Increment a counter by 1.
  public fun increment(counter: &mut Counter) {
    counter.value = counter.value + 1;
  }

  public fun getCounts (collectionCounters: &mut CountersCollection ) : vector<CounterStored>
  {
    return collectionCounters.counters
  }
  /// Set value (only runnable by the Counter owner)
  public fun set_value(counter: &mut Counter, value: u64, ctx: &TxContext) {
    assert!(counter.owner == ctx.sender(), 0);
    counter.value = value;
  }
}
