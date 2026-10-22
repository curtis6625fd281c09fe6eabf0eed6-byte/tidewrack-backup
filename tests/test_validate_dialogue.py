import unittest
from validate_dialogue import validate_graph

class ValidatorTests(unittest.TestCase):
    def test_disconnected_ending_does_not_validate_loop(self):
        errors, _ = validate_graph({'start': {'text': 'loop', 'next': 'start'}, 'end': {'text': 'unused', 'next': None}}, {'start'})
        self.assertTrue(any('no reachable ending' in e for e in errors))

    def test_choice_into_closed_loop_is_rejected(self):
        errors, _ = validate_graph({'start': {'text': '', 'choices': [{'text': 'exit', 'next': None}, {'text': 'loop', 'next': 'loop'}]}, 'loop': {'text': '', 'next': 'loop'}}, {'start'})
        self.assertTrue(any('dead-end loop' in e for e in errors))

    def test_malformed_nodes_and_choices_do_not_crash(self):
        for value in [None, [], {'start': 3}, {'start': {'text': '', 'choices': [42]}}]:
            errors, _ = validate_graph(value, {'start'})
            self.assertTrue(errors)

    def test_flags_and_missing_targets(self):
        errors, _ = validate_graph({'start': {'text': '', 'next': 'missing', 'set_flag': {'x': []}}}, {'start'})
        self.assertGreaterEqual(len(errors), 2)

    def test_valid_branching_graph(self):
        errors, _ = validate_graph({'start': {'text': '', 'choices': [{'text': 'yes', 'next': 'end', 'set_flag': {'yes': True}}]}, 'end': {'text': '', 'next': None}}, {'start'})
        self.assertFalse(errors)

if __name__ == '__main__':
    unittest.main()
