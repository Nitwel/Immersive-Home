# HomeApi

The `HomeApi` is a global singleton that is used to communicate with the smart home environment. It is responsible for fetching the current state of the environment and sending commands to the environment.

::: info
It is possible to write your own adapters for different smart home environments. For the time being, only Home Assistant is supported and extended by us. If you want to add support for another smart home environment, please reach out to us on [GitHub](https://github.com/nitwel/immersive-home) or [Discord](https://discord.gg/QgUnAzNVTx).
:::

For detailed information on how to use the `HomeApi`, please refer to the [Reference](/reference/lib--globals--home_api.html).