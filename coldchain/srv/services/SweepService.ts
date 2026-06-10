import {Batches, SweepRuns, Batch_expiryStatus} from '#cds-models/ColdChainService';
import cds from '@sap/cds';

export class SweepService {
    constructor(private readonly srv: cds.Service){} 

    classify(expiryDate: string): Batch_expiryStatus{
        const today = new Date();
        today.setHours(0,0,0,0);
        const expiry = new Date(expiryDate);
        const daysLeft = Math.ceil((expiry.getTime() - today.getTime()) / 86_400_000);

        if(daysLeft < 0) return 'Expired';
        if (daysLeft <= 2) return 'Critical';
        if (daysLeft <= 5) return 'UseSoon';

        return 'Fresh';
    }

    async run(){
        const run = await INSERT.into(SweepRuns).entries({
            runAt: new Date().toISOString(),
            status: 'running'
        });

        const runID = run.results?.[0]?.ID ?? (await SELECT.one.from(SweepRuns).orderBy('runAt desc'))?.ID;

        const batches = await SELECT.from(Batches).where({quantityOnHand : {'>': 0}});
        let scanned = 0;
        let reclassified = 0; 
        let expired = 0;
        for (const b of batches){
            scanned++;
            const newStatus = this.classify(b.expiryDate!);
            if(newStatus !== b.expiryStatus){
                await UPDATE(Batches).set({expiryStatus: newStatus}).where({ID: b.ID});
                reclassified++;
                if(newStatus === 'Expired') expired++;
            }
        }

        await UPDATE(SweepRuns).set({
            batchesScanned: scanned,
            flaggedCount: reclassified,
            expiredCount: expired,
            status: 'completed'
        }).where({ID: runID});

        return `Sweep complete: ${scanned} scanned, ${reclassified} reclassified (${expired} expired).`;
    }
}