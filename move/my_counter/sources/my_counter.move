module my_counter::my_counter {

    use sui::table::{Self, Table};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};
    use std::string::String;
    use std::vector;

    use sui::event;
    

    public struct CounterCreated  {
        counterId: address,
        CountersCollection:  Table<address, Counter>


    }
    /// A shared counter.
    public struct Counter has store, key {
        id: UID,
        owner: address,
        value: u64
    }

    public struct CountersCollection has key, store {
        id: UID,
        counters: Table<address, Counter>
    }

    /// Create and share a Counter object.
    public fun create(ctx: &mut TxContext, collection: &mut CountersCollection) {
        let counter = Counter {
            id: object::new(ctx),
            owner: ctx.sender(),
            value: 0
        };
        transfer::share_object(counter);
    }
  
    /// Create and store a Counter object in the table.
    public fun create_and_store(collection: &mut CountersCollection, ctx: &mut TxContext) {
        let id_of_new_counter = object::new(ctx);
        let counter = Counter {
            id: id_of_new_counter,
            owner: ctx.sender(),
            value: 0
        };
  
        let address_of_counter = object::uid_to_address(&counter.id);
        table::add(&mut collection.counters, address_of_counter, counter);
        //     event::emit(CounterCreated{
        //             counterId: counter.id_of_new_counter,
        //              CountersCollection: table

        // });
    }

    /// Increment a counter by 1.
    public fun increment(counter: &mut Counter, collection: &mut CountersCollection) {
        counter.value = counter.value + 1;
        let address_of_counter = object::uid_to_address(&counter.id);
        increment_in_collection(collection, address_of_counter);
    }

    /// Set value (only runnable by the Counter owner).
    public fun set_value(counter: &mut Counter, value: u64, collection: &mut CountersCollection, ctx: &TxContext) {
        assert!(counter.owner == ctx.sender(), 0);
        counter.value = value;
    }

    /// Increment a counter in the collection by 1.
    public fun increment_in_collection(collection: &mut CountersCollection, address_of_counter: address) {
        let counter = table::borrow_mut(&mut collection.counters, address_of_counter);
        counter.value = counter.value + 1;  
    }

    /// Set value of a counter in the collection (only runnable by the Counter owner).
    public fun set_value_in_collection(collection: &mut CountersCollection, name: address, value: u64, ctx: &TxContext) {
        let counter = table::borrow_mut(&mut collection.counters, name);
        assert!(counter.owner == ctx.sender(), 0);
        counter.value = value;
    }

    /// Initialize a new CountersCollection.
    // public fun create_collection(ctx: &mut TxContext): CountersCollection {
    //     CountersCollection {
    //         id: object::new(ctx),
    //         counters: table::new(ctx)
    //     }
    // }

    /// Get the value of a counter.
    public fun get_counter_value(collection: &CountersCollection, name: address): u64 {
        let counter = table::borrow(&collection.counters, name);
        counter.value
    }

    /// Return all values in the table.
    // public fun get_all_counter_values(collection: &CountersCollection): vector<u64> {
    //     // let mut values: vector<u64> = vector::empty();
    //     // let keys = table::keys(&collection.counters)
    //     // // for key in keys {
    //     // //     let counter = table::borrow(&collection.counters, key);
    //     // //     vec::push_back(&mut values, counter.value);
    //     // // }
    //     // values
    // }
}
