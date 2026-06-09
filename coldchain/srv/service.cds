using coldchain from '../db/schema';

@path: '/coldchain'
service ColdChainService {
  @singular: 'Product'         @plural: 'Products'
  entity Products          as projection on coldchain.Products;
  @singular: 'ProductCategory' @plural: 'ProductCategories'
  entity ProductCategories as projection on coldchain.ProductCategories;
  @singular: 'Supplier'        @plural: 'Suppliers'
  entity Suppliers         as projection on coldchain.Suppliers;
  @singular: 'StorageLocation' @plural: 'StorageLocations'
  entity StorageLocations  as projection on coldchain.StorageLocations;
  @singular: 'PricingRule'     @plural: 'PricingRules'
  entity PricingRules      as projection on coldchain.PricingRules;
  @singular: 'Batch'           @plural: 'Batches'
  @odata.draft.enabled
  entity Batches           as projection on coldchain.Batches;
  @singular: 'Order'           @plural: 'Orders'
  entity Orders            as projection on coldchain.Orders;
  @singular: 'OrderLineItem'   @plural: 'OrderLineItems'
  entity OrderLineItems    as projection on coldchain.OrderLineItems;
  @singular: 'Allocation'      @plural: 'Allocations'
  entity Allocations       as projection on coldchain.Allocations;
  @singular: 'DisposalRecord'  @plural: 'DisposalRecords'
  entity DisposalRecords   as projection on coldchain.DisposalRecords;
  @singular: 'BatchAction'     @plural: 'BatchActions'
  entity BatchActions      as projection on coldchain.BatchActions;
  @singular: 'SweepRun'        @plural: 'SweepRuns'
  entity SweepRuns         as projection on coldchain.SweepRuns;
}