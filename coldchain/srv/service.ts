import cds from '@sap/cds';
import { Batches } from '#cds-models/ColdChainService';
import { SweepService } from './services/SweepService';

export class ColdChainService extends cds.ApplicationService {
    async init() {
        //add before and after logic for handlers here if needed
        
        const sweep = new SweepService(this);
        this.on('runSweep', ()=> sweep.run());
        this.before('CREATE', Batches, async (req) => {
            const { maxNo } = await SELECT.one`max(batchNo) as maxNo`.from(Batches) as unknown as { maxNo: number | null };
            req.data.batchNo = (maxNo ?? 10000) + 1; //5-digit for human readability and consistency
        });
        await super.init();
    }
}
