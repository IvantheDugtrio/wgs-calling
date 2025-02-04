import pytest

from lib import resource_calculator as rc


@pytest.fixture
def partition_set():
    partitions = {"small": ["q1", "q2", "q3"], "large": ["q4", "q5"], "huge": ["q6"]}
    return partitions


@pytest.mark.parametrize(
    "selected_partition,expected_partitions",
    [("small", ["q1", "q2", "q3"]), ("large", ["q4", "q5"]), ("huge", ["q6"])],
)
def test_select_partition(partition_set, selected_partition, expected_partitions):
    """
    Test select_partition when the user selection is valid
    """
    res = [rc.select_partition(selected_partition, partition_set) for i in range(100)]
    assert set(res) == set(expected_partitions)


def test_select_partition_invalid_selection(partition_set):
    """
    Test select_partition when the user selection is invalid
    """
    with pytest.raises(
        ValueError,
        match=r"Configured partition set does not match anything in user resource config.*",
    ):
        rc.select_partition("fake_partition", partition_set)
