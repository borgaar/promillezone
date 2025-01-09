import type { TrashProvider } from "./provider";
import TRV from "./provider/trv";

class TrashProviderFactory {
  private static providers: Record<string, TrashProvider> = {};

  static register(provider: TrashProvider) {
    TrashProviderFactory.providers[provider.slug] = provider;
  }

  static get(slug: string): TrashProvider | null {
    const provider = TrashProviderFactory.providers[slug];

    if (!provider) {
      return null;
    }

    return provider;
  }

  static getAll(): TrashProvider[] {
    return Object.values(TrashProviderFactory.providers);
  }
}

// REGISTER ALL PROVIDERS HERE
TrashProviderFactory.register(new TRV());

export { TrashProviderFactory };
