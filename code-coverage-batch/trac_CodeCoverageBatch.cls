/**
 * @description Code Coverage class to run daily job to make sure org is up to par
 * @author Simon Salvatore, Traction on Demand
 * @date November 27, 2020
 */
global class trac_CodeCoverageBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Product2 LIMIT 1');
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        trac_CodeCoverageHelper.getCodeCoverage();
    }

    global void finish(Database.BatchableContext bc) {

    }

    global void execute(SchedulableContext sc) {
        trac_CodeCoverageHelper.futureGetCodeCoverage();
    }
}