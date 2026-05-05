---
to: .env.development
---
<%_ if (projectType === 'expo') { _%>
EXPO_PUBLIC_BASE_URL=http://localhost:3000
EXPO_PUBLIC_SHOW_STORYBOOK=false
<%_ } else { _%>
BASE_URL=http://localhost:3000
SHOW_STORYBOOK=false
<%_ } _%>
