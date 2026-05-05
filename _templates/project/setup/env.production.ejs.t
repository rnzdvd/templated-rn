---
to: .env.production
---
<%_ if (projectType === 'expo') { _%>
EXPO_PUBLIC_BASE_URL=https://api.yourapp.com
EXPO_PUBLIC_SHOW_STORYBOOK=false
<%_ } else { _%>
BASE_URL=https://api.yourapp.com
SHOW_STORYBOOK=false
<%_ } _%>
