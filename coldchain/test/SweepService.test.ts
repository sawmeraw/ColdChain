import cds from '@sap/cds';
import { describe, it } from 'node:test';
import { SweepService } from '../srv/services/SweepService';

const test = cds.test(cds.root);
const { GET, expect } = test;

const dateInDays = (n: number): string => {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + n);
    return d.toISOString().slice(0, 10);
};

//unit test
describe('SweepService.classify', () => {
    const sweep = new SweepService(null as never);

    it('returns Fresh for far-future expiry', () => {
        expect(sweep.classify(dateInDays(30))).to.equal('Fresh');
    });
    it('returns UseSoon at the 5-day boundary', () => {
        expect(sweep.classify(dateInDays(5))).to.equal('UseSoon');
    });
    it('returns Critical at the 2-day boundary', () => {
        expect(sweep.classify(dateInDays(2))).to.equal('Critical');
    });
    it('returns Expired for a past date', () => {
        expect(sweep.classify(dateInDays(-1))).to.equal('Expired');
    });
});

//integration test
describe('ColdChainService', () => {
    it('serves the seeded batches over OData', async () => {
        const { data } = await GET('/coldchain/Batches');
        expect(data.value).to.be.an('array').that.is.not.empty;
    });

    it('serves batches via the programmatic service API (no HTTP)', async () => {
        const srv = await cds.connect.to('ColdChainService');
        const { Batches } = await import('#cds-models/ColdChainService');

        const fresh = await srv.read(Batches)
            .columns('ID', 'batchNo', 'expiryStatus')
            .where({ expiryStatus: 'Fresh' })
            .orderBy('batchNo')
            .limit(5);

        const same = await srv.run(
            SELECT.from(Batches).columns('ID', 'batchNo').where({ expiryStatus: 'Fresh' })
        );

        expect(fresh).to.be.an('array');
        expect(fresh.length).to.equal(same.length);
    });

    it('records a SweepRun when run() executes', async () => {
        const srv = await cds.connect.to('ColdChainService');
        const { SweepRuns } = await import('#cds-models/ColdChainService');

        const countBefore = (await SELECT.from(SweepRuns)).length;
        await new SweepService(srv).run();
        const countAfter = (await SELECT.from(SweepRuns)).length;

        expect(countAfter).to.equal(countBefore + 1);
    });
});
