using coldchain from '../db/schema';

service ColdChainService {
  entity Products          as projection on coldchain.Products;
  entity ProductCategories as projection on coldchain.ProductCategories;
  entity Suppliers         as projection on coldchain.Suppliers;
  entity StorageLocations  as projection on coldchain.StorageLocations;
  entity PricingRules      as projection on coldchain.PricingRules;
  entity Batches           as projection on coldchain.Batches;
  entity Orders            as projection on coldchain.Orders;
  entity OrderLineItems    as projection on coldchain.OrderLineItems;
  entity Allocations       as projection on coldchain.Allocations;
  entity DisposalRecords   as projection on coldchain.DisposalRecords;
  entity BatchActions      as projection on coldchain.BatchActions;
  entity SweepRuns         as projection on coldchain.SweepRuns;
}