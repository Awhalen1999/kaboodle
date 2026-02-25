# Provider Reference

## packingListsProvider
**Owns:** List of packing lists, live count
**Loads:** On app start / after login
**Local mutations:** `addPackingList()`, `updatePackingList()`, `removePackingList()` — no API call, instant
**Refresh (API reload):** After delete, reset progress, update dates, all items packed, error retry
**Clear:** On logout

## subscriptionProvider
**Owns:** `isPro`, `expiresAt`, `startedAt`, `cancelledAt`
**Does NOT own:** List count (use `packingListsProvider.length`), canCreateList, maxFreeLists
**Loads:** On app start / after login
**Refresh:** After purchase, restore, RevenueCat push, error retry
**Clear:** On logout

## userProvider
**Owns:** `displayName`, `photoUrl`, `country`
**Loads:** On app start / after login
**Refresh:** On error retry
**Mutate:** `updateUserProfile()` — updates local state on success
**Clear:** On logout

## usePackingItemsProvider(listId)
**Owns:** Items for one list
**Loads:** When use-list screen opens
**Local mutations:** `toggleItemPacked()`, `checkAllItems()`, `uncheckAllItems()`, `discardChanges()`
**Save:** `saveProgress()` — diffs against original, bulk updates only changed items
**Refresh:** After reset progress, error retry

## themeProvider
**Owns:** Color mode preference
**Loads:** From Hive on app start
**Mutate:** `setThemeMode()` — persists to Hive immediately

---

## Rules
1. List count always comes from `packingListsProvider.length` — never from `subscriptionProvider`
2. `maxFreeLists = 2` is a hardcoded constant, not fetched from API
3. Use local mutations over `refresh()` where possible — avoids unnecessary API calls
4. `subscriptionProvider.refresh()` is only for subscription events (purchase/restore/RevenueCat)
5. Logout order: Firebase signout → clear providers (auth first, state second)
