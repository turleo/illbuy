import "../src/index.css";
import { initialize, mswLoader } from "msw-storybook-addon";
import { render } from "solid-js/web";

initialize();

export const decorators = [
  (Story) => {
    const solidRoot = document.createElement("div");

    render(Story, solidRoot);

    return solidRoot;
  },
];

export default {
  loaders: [mswLoader],
};
