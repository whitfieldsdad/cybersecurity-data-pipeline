from metaflow import step
from pipeline.flows.base.flow import BaseFlow


class Flow(BaseFlow):
    @step
    def start(self):
        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
