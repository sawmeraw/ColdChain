namespace coldchain;
using { cuid, managed } from '@sap/cds/common';

aspect deactivatable {
  isActive : Boolean default true not null;
}

@singular : 'ProductCategory'
@plural   : 'ProductCategories'
entity ProductCategories : cuid, managed {
  name                 : String not null;
  parent               : Association to ProductCategories;
  children             : Composition of many ProductCategories on children.parent = $self;
  defaultShelfLifeDays : Integer;
  products             : Composition of many Products     on products.category    = $self;
  pricingRules         : Composition of many PricingRules on pricingRules.category = $self;
}

@singular : 'Product'
@plural   : 'Products'
entity Products : cuid, managed, deactivatable {
  sku           : String not null;
  name          : String not null;
  category      : Association to ProductCategories;
  basePrice     : Decimal(9,2) not null;                         // reference price
  storageClass  : String enum { frozen; chilled; ambient } not null;
  shelfLifeDays : Integer;
  s4MaterialNo  : String;                                        // integration column with s4 mm
  batches       : Composition of many Batches on batches.product = $self;
}

@singular : 'Supplier'
@plural   : 'Suppliers'
entity Suppliers : cuid, deactivatable {
  name              : String not null;
  s4BusinessPartner : String;
}

@singular : 'StorageLocation'
@plural   : 'StorageLocations'
entity StorageLocations : cuid {
  code            : String not null;
  temperatureZone : String enum { frozen; chilled; ambient } not null;
  capacityUnits   : Integer;
}

@singular : 'PricingRule'
@plural   : 'PricingRules'
entity PricingRules : cuid {
  category        : Association to ProductCategories not null;
  appliesToStatus : String enum { Fresh; UseSoon; Critical } not null; //expired isnt sold
  discountPercent : Decimal(5,2) not null;
}

@singular : 'Batch'
@plural   : 'Batches'
entity Batches : cuid, managed {
  batchNo          : Integer @title: 'Batch #';
  product          : Association to Products not null;
  location         : Association to StorageLocations;
  supplier         : Association to Suppliers;                   //we buy from suppliers
  productionDate   : Date;
  expiryDate       : Date not null;
  quantityReceived : Integer not null;                           // immutable: total at goods receipt
  quantityOnHand   : Integer not null;                           // live balance; only changed via movements
  unitCost         : Decimal(9,2) not null;                      // purchase cost
  currentUnitPrice : Decimal(9,2) not null;                      // live sell price, maintained via repricing rules
  expiryStatus     : String enum { Fresh; UseSoon; Critical; Expired } default 'Fresh' not null;
  allocations      : Composition of many Allocations     on allocations.batch = $self;
  disposals        : Composition of many DisposalRecords on disposals.batch   = $self;
  actions          : Composition of many BatchActions    on actions.batch     = $self;
}

@singular : 'Order'
@plural   : 'Orders'
entity Orders : cuid, managed {
  orderNo   : Integer @title: 'Order #';                         // human-readable, assigned in handler
  customer  : String not null;
  status    : String enum { open; allocated; dispatched; delivered; cancelled } default 'open' not null;
  lineItems : Composition of many OrderLineItems on lineItems.order = $self;
}

@singular : 'OrderLineItem'
@plural   : 'OrderLineItems'
entity OrderLineItems : cuid {
  order             : Association to Orders not null;
  product           : Association to Products not null;
  quantity          : Integer not null;                          // requested
  quantityFulfilled : Integer default 0 not null;                // allocated so far (maintained total)
  fulfillmentStatus : String enum { open; partial; fulfilled; cancelled } default 'open' not null;
  allocations       : Composition of many Allocations on allocations.orderLineItem = $self;
}

// Link entity: OrderLineItem ↔ Batch (FEFO) + frozen price snapshot
@singular : 'Allocation'
@plural   : 'Allocations'
entity Allocations : cuid, managed {
  orderLineItem         : Association to OrderLineItems not null;
  batch                 : Association to Batches not null;
  quantityAllocated     : Integer not null;
  unitPriceAtAllocation : Decimal(9,2) not null;                 // price FROZEN at point of sale
}

@singular : 'DisposalRecord'
@plural   : 'DisposalRecords'
entity DisposalRecords : cuid, managed {
  batch       : Association to Batches not null;
  quantity    : Integer not null;
  reason      : String enum { expired; damaged; recalled } not null;
  costOfWaste : Decimal(11,2) not null;
  notes       : String not null;                                 // required
}

// Output of the nightly sweep: an actionable item about an at-risk batch
@singular : 'BatchAction'
@plural   : 'BatchActions'
entity BatchActions : cuid, managed {
  batch    : Association to Batches not null;
  sweepRun : Association to SweepRuns;                            // which run raised it (optional link for traceability)
  type     : String enum { reprice; expediteDispatch; dispose; alert } not null;
  status   : String enum { open; done; dismissed } default 'open' not null;
  notes    : String not null;                                    // required
}

// Observability: one row per sweep execution
@singular : 'SweepRun'
@plural   : 'SweepRuns'
entity SweepRuns : cuid {
  runAt          : Timestamp not null;
  batchesScanned : Integer default 0 not null;
  repricedCount  : Integer default 0 not null;
  expiredCount   : Integer default 0 not null;
  flaggedCount   : Integer default 0 not null;
  status         : String enum { running; completed; failed } default 'running' not null;
  notes          : String;
}