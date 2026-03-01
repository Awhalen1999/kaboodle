# Analytics Events

All events automatically include the logged-in user ID via Posthog's `identify()` call on sign-in.

**List props** — all optional, only sent if the user filled them in:

| Prop | Type | Notes |
|---|---|---|
| `list_name` | String | The trip/list name |
| `destination` | String | Country code (e.g. `"US"`) |
| `purpose` | String | e.g. `"business"`, `"leisure"` |
| `gender` | String | e.g. `"male"`, `"female"` |
| `item_count` | int | Total items selected — `list_created` only |

---

## Auth

| Event | When | Props |
|---|---|---|
| *(identify)* | Sign in / app launch | `userId` |
| *(reset)* | Sign out | — |

## Lists

| Event | When | Props |
|---|---|---|
| `list_created` | User finishes the create flow | list props + `item_count` |
| `list_opened` | User opens a list to pack | list props |
| `list_finished` | User packs all items and saves | list props |
| `list_deleted` | User deletes a list | list props |

## Subscription

| Event | When | Props |
|---|---|---|
| `paywall_viewed` | Paywall screen opens | — |
| `subscription_started` | User subscribes | `package` |
| `subscription_management_opened` | User opens manage subscription | — |
