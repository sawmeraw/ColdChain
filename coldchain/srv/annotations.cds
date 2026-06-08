using ColdChainService from './service';

annotate ColdChainService.Batches with @(
    UI: {
        SelectionFields: [expiryStatus, product_ID],
        LineItem: [
            {Value: batchNo, Label: 'Batch #'},
            {Value: product_ID, Label: 'Product ID'},
            {Value: expiryDate, Label: 'Expiry'},
            {Value: expiryStatus, Label: 'Expiry Status'},
            {Value: quantityOnHand, Label: 'Qty on Hand'},
            {Value: currentUnitPrice, Label: 'Price'},
        ],
        HeaderInfo:{
            TypeName: 'Batch', TypeNamePlural: 'Batches', Title: {Value: batchNo}, Description: {Value: expiryStatus}
        }
    }
);