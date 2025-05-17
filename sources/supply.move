module debayudh::SupplierBidding {
    use aptos_framework::signer;
    use std::vector;
    use std::option::{Self, Option};

    /// Error codes
    const E_BID_TOO_LOW: u64 = 1;
    const E_BIDDING_CLOSED: u64 = 2;
    const E_NOT_PROJECT_OWNER: u64 = 3;

    /// Struct representing a bid from a supplier
    struct Bid has store, drop, copy {
        supplier: address,
        amount: u64,
        proposal: vector<u8>
    }

    /// Struct representing a project open for bidding
    struct Project has key {
        owner: address,
        description: vector<u8>,
        min_bid: u64,
        bids: vector<Bid>,
        is_active: bool,
        winning_bid: Option<Bid>
    }

    /// Create a new project for suppliers to bid on
    public entry fun create_project(
        owner: &signer,
        description: vector<u8>,
        min_bid: u64
    ) {
        let project = Project {
            owner: signer::address_of(owner),
            description,
            min_bid,
            bids: vector::empty<Bid>(),
            is_active: true,
            winning_bid: option::none()
        };
        move_to(owner, project);
    }

    /// Submit a bid for a project
    public entry fun submit_bid(
        supplier: &signer,
        project_owner: address,
        amount: u64,
        proposal: vector<u8>
    ) acquires Project {
        let project = borrow_global_mut<Project>(project_owner);
        assert!(project.is_active, E_BIDDING_CLOSED);
        assert!(amount >= project.min_bid, E_BID_TOO_LOW);

        let bid = Bid {
            supplier: signer::address_of(supplier),
            amount,
            proposal
        };
        vector::push_back(&mut project.bids, bid);
    }
}
