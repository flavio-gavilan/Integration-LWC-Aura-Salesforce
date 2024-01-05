public with sharing class AccountCrudModalsController {
    public static final String UPDATE_SUCESS = 'Record Updated.';
    public static final String RECORD_ERROR  = 'Something got wrong. ';
    @AuraEnabled
    public static List<Account> searchAccounts(String accountName) {
        String searchFilterLike = '%' + accountName + '%';
        return [SELECT Id, Name, Type, Phone, Website
                FROM Account
                WHERE Name LIKE :searchFilterLike
                WITH Security_Enforced];
    }

    @AuraEnabled
    public static Account searchAccountById(Id accountId) {
        return [SELECT Id, Name, Type, Phone, Website
                FROM Account
                WHERE Id =:accountId
                WITH Security_Enforced];
    }

    @AuraEnabled
    public static String saveRecords(String accountJSON){
        try {
            Map<String, Account> mapAccNameAccount = mapAccNameAccount(accountJSON);
            List<Account> listAccounts = new List<Account>();

            for(Account acc : mapAccNameAccount.values()){
                Account account = new Account();

                if(acc.Id != null){
                    account.Id = acc.Id;
                }
                account.Name = acc.Name;
                account.Type = acc.Type;
                account.Phone = acc.Phone;
                account.Website = acc.Website;
                listAccounts.add(account);
            }
            Database.upsert(listAccounts, true);

            return UPDATE_SUCESS;
        } catch (Exception e) {
            return RECORD_ERROR + e.getMessage();
        }
    }

    @AuraEnabled
    public static void deleteRecord(Id recordId){
        Account accDelete = [SELECT Id FROM Account WHERE Id =: recordId WITH Security_Enforced];
        Database.delete(accDelete, true);
    }

    private static Map<String, Account> mapAccNameAccount(String accountJSON){
        Map<String, Object> mapStringObject = (Map<String, Object>) JSON.deserializeUntyped(accountJSON);
        Map<String, Account> mapAccNameAccount = new Map<String, Account>();
        
        for(String key : mapStringObject.keySet()){
            Account account = new Account();
            account.Id      = String.valueOf(mapStringObject.get('accId'));
            account.Name    = String.valueOf(mapStringObject.get('nome'));
            account.Type    = String.valueOf(mapStringObject.get('type'));
            account.Phone   = String.valueOf(mapStringObject.get('phone'));
            account.Website = String.valueOf(mapStringObject.get('website'));
            mapAccNameAccount.put(account.Name, account);
        }

        return mapAccNameAccount;
    }
}