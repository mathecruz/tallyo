import { definePreset } from '@primeuix/themes';
import Aura from '@primeuix/themes/aura';

// Tallyo brand palette
// Primary Blue #0F5FFF · Accent Green #12B886 · Dark Navy #2B3350
// Light Gray #B9BCC8 · Mid Gray #9A9DA8 · White #FFFFFF
export const TallyoPreset = definePreset(Aura, {
  primitive: {
    borderRadius: {
      none: '0',
      xs: '4px',
      sm: '6px',
      md: '10px',
      lg: '12px',
      xl: '16px',
    },
    blue: {
      50: '#eef4ff',
      100: '#d9e6ff',
      200: '#b3ccff',
      300: '#80aaff',
      400: '#4d86ff',
      500: '#0f5fff',
      600: '#0b4fdb',
      700: '#0940b3',
      800: '#08348f',
      900: '#072b73',
      950: '#041a47',
    },
    green: {
      50: '#e7f8f2',
      100: '#c3eedf',
      200: '#8fdfc4',
      300: '#55cda5',
      400: '#2ec293',
      500: '#12b886',
      600: '#0e9a70',
      700: '#0b7b5a',
      800: '#095f46',
      900: '#074c39',
      950: '#032b20',
    },
    navy: {
      50: '#f7f8fa',
      100: '#eef0f4',
      200: '#dfe1e8',
      300: '#b9bcc8',
      400: '#9a9da8',
      500: '#6f7385',
      600: '#4f5468',
      700: '#2b3350',
      800: '#222940',
      900: '#1a1f31',
      950: '#11141f',
    },
  },
  semantic: {
    primary: {
      50: '{blue.50}',
      100: '{blue.100}',
      200: '{blue.200}',
      300: '{blue.300}',
      400: '{blue.400}',
      500: '{blue.500}',
      600: '{blue.600}',
      700: '{blue.700}',
      800: '{blue.800}',
      900: '{blue.900}',
      950: '{blue.950}',
    },
    colorScheme: {
      light: {
        surface: {
          0: '#ffffff',
          50: '{navy.50}',
          100: '{navy.100}',
          200: '{navy.200}',
          300: '{navy.300}',
          400: '{navy.400}',
          500: '{navy.500}',
          600: '{navy.600}',
          700: '{navy.700}',
          800: '{navy.800}',
          900: '{navy.900}',
          950: '{navy.950}',
        },
      },
    },
  },
  components: {
    button: {
      root: {
        borderRadius: '9999px',
      },
    },
    card: {
      root: {
        shadow:
          '0 1px 2px 0 rgba(43, 51, 80, 0.04), 0 4px 16px -4px rgba(43, 51, 80, 0.08)',
      },
    },
    tag: {
      root: {
        borderRadius: '9999px',
        fontWeight: '600',
      },
    },
  },
});
