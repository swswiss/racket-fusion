import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.hideAfterDelay();
  }

  hideAfterDelay() {
    setTimeout(() => {
      this.element.remove();
    }, 5000); // 5000 milliseconds = 5 seconds
  }
}