using ColdChainService from '../srv/service.cds';

annotate ColdChainService.Batches with {
    product @(
        Common.Text          : product.name,
        Common.TextArrangement: #TextOnly
    );
    supplier @(
        Common.Text          : supplier.name,
        Common.TextArrangement: #TextOnly
    );
    location @(
        Common.Text          : location.code,
        Common.TextArrangement: #TextOnly
    );
    batchNo @readonly;
    productionDate @readonly;
    expiryStatus @readonly;
    quantityOnHand @readonly;
};


annotate ColdChainService.Batches with @(
    UI: {
        LineItem: [
            {Value: batchNo, Label: 'Batch #'},
            {Value: product_ID, Label: 'Product'},
            {Value: productionDate, Label: 'Production Date'},
            {Value: expiryDate, Label: 'Expiry'},
            {Value: expiryStatus, Label: 'Expiry Status'},
            {Value: quantityOnHand, Label: 'Qty on Hand'},
            {Value: currentUnitPrice, Label: 'Price'},
            {Value: supplier_ID, Label: 'Supplier'},
            {Value: location_ID, Label: 'Storage Location'},
        ],
        HeaderInfo:{
            TypeName: 'Edit Batch', TypeNamePlural: 'Batches', Title: {Value: product.name}, Description: {Value: batchNo}
        },
        Facets: [
            {$Type: 'UI.ReferenceFacet', Label: 'Batch Details', Target: '@UI.FieldGroup#Main'}
        ],
        FieldGroup #Main: {
            Data: [
                {Value: product_ID, Label: 'Product'},
                {Value: batchNo, Label: 'Batch #'},
                {Value: productionDate, Label: 'Production Date'},
                {Value: expiryDate, Label: 'Expiry Date'},
                {Value: expiryStatus, Label: 'Expiry Status'},
                {Value: quantityOnHand, Label: 'Quantity on Hand'},
                {Value: currentUnitPrice, Label: 'Current Unit Price'},
                {Value: supplier_ID, Label: 'Supplier'},
                {Value: location_ID, Label: 'Storage Location'},
            ]
        },
        
    }
);